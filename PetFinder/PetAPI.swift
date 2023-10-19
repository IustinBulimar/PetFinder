//
//  API.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import Foundation
import RxSwift
import RxCocoa


enum HTTPMethod: String {
    case get
    case post
}

enum APIEndpoint: String {
    case authentication = "oauth2/token"
    case animals = "animals"
}

class PetAPI {
    
    private let baseUrl = URL(string: "https://api.petfinder.com/v2")!
    
    private let session: URLSession
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fullUrl(for endpoint: APIEndpoint) -> URL {
        baseUrl.appendingPathComponent(endpoint.rawValue)
    }

    private func createRequest(endpoint: APIEndpoint, method: HTTPMethod, params: [String: String]? = nil, headers: [String: String]? = nil) -> URLRequest {
        let url = fullUrl(for: endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()

        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let params = params {
            switch method {
            case .get:
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                urlComponents?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
                if let updatedURL = urlComponents?.url {
                    request.url = updatedURL
                }
            default:
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = params.map { "\($0.key)=\($0.value)" }
                                         .joined(separator: "&")
                                         .data(using: .utf8)
            }
        }
        
        return request
    }
    
    private func performRequest<Model: Codable>(endpoint: APIEndpoint, method: HTTPMethod, params: [String: String]? = nil, headers: [String: String]? = nil) -> Observable<Model> {
        let request = createRequest(endpoint: endpoint, method: method, params: params, headers: headers)
        
        return session.rx.response(request: request)
            .flatMap { (response, data) -> Observable<Data> in
                if response.statusCode == 401 {
                    return Observable.error(AppError.invalidCredentials)
                }
                
                guard 200..<300 ~= response.statusCode else {
                    return Observable.error(AppError.badRequest(statusCode: response.statusCode))
                }
                
                return Observable.just(data)
            }
            .decode(type: Model.self, decoder: self.decoder)
    }
    
    func getAccessToken() -> Observable<String> {
        guard let infoDict = Bundle.main.infoDictionary,
              let clientId = infoDict["ClientId"] as? String,
              let clientSecret = infoDict["ClientSecret"] as? String else {
            fatalError("Missing Secrets.xcconfig file")
        }
        
        if let token = AuthManager.shared.validAccessToken {
            return Observable.just(token)
        } 
        
        let params = [
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret
        ]
        
        return performRequest(endpoint: .authentication, method: .post, params: params)
            .do { (authResponse: AuthResponse) in
                AuthManager.shared.update(token: authResponse.accessToken, expiresIn: authResponse.expiresIn)
            }
            .map { _ in AuthManager.shared.validAccessToken }
            .compactMap { $0 }
    }
    
    private func performAuthenticatedRequest<Model: Codable>(endpoint: APIEndpoint, method: HTTPMethod, params: [String: String]? = nil) -> Observable<Model> {
        
        return getAccessToken()
            .flatMap { accessToken -> Observable<Model> in
                let headers = [
                    "Authorization": "Bearer \(accessToken)"
                ]
                
                return self.performRequest(endpoint: endpoint, method: method, params: params, headers: headers)
            }
    }
    
    func getAnimals(type: String, page: Int) -> Observable<AnimalResponse> {
        let params = [
            "type": type,
            "page": String(page)
        ]
        
        return performAuthenticatedRequest(endpoint: .animals, method: .get, params: params)
    }
}
