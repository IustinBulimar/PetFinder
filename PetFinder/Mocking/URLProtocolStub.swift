//
//  URLProtocolStub.swift
//  PetFinderTests
//
//  Created by Iustin Bulimar on 20.10.2023.
//

import Foundation


class URLProtocolStub: URLProtocol {
    private static var stubs: [URL: Stub] = [:]
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func stopLoading() {}
    
    override func startLoading() {
        if let url = request.url {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.query = nil
            
            if let querylessUrl = urlComponents?.url,
               let stub = URLProtocolStub.stubs[querylessUrl] {
                
                if let data = stub.data {
                    client?.urlProtocol(self, didLoad: data)
                }
                
                if let response = stub.response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                
                if let error = stub.error {
                    client?.urlProtocol(self, didFailWithError: error)
                }
            }
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    static func setStub<T: Decodable>(for url: URL, mockType: T.Type, statusCode: Int, error: Error?) throws {
        stubs[url] = Stub(data: try getMockData(forType: mockType),
                          response: HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!,
                          error: error)
    }
    
    static func resetStubs() {
        stubs = [:]
    }
    
}

fileprivate func getMockData<T: Decodable>(forType type: T.Type) throws -> Data {
    let typeName = String(describing: type)
    let fileName = "Mock\(typeName)"
    
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        throw AppError.fileNotFound(fileName: fileName)
    }
    
    let mockData = try Data(contentsOf: url)
    return mockData
}

func getMock<T: Decodable>(forType type: T.Type) throws -> T {
    let data = try getMockData(forType: type)
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    let model = try decoder.decode(type, from: data)
    return model
}
