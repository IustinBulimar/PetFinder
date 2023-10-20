//
//  PetsApiTests.swift
//  PetFinderTests
//
//  Created by Iustin Bulimar on 20.10.2023.
//

import XCTest
import RxSwift

@testable import PetFinder

final class PetsApiTests: XCTestCase {
    
    var api: PetAPI!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        api = PetAPI(session: session)
        disposeBag = DisposeBag()
        URLProtocolStub.resetStubs()
        AuthManager.shared.eraseData()
        
    }

    override func tearDownWithError() throws {
        api = nil
        disposeBag = nil
        URLProtocolStub.resetStubs()
        AuthManager.shared.eraseData()
    }
    
    func testCachedAccessToken() {
        let cachedToken = "cached token"
        AuthManager.shared.update(token: cachedToken, expiresIn: 10)
        do {
            try URLProtocolStub.setStub(for: api.fullUrl(for: .authentication),
                                        mockType: AuthResponse.self,
                                        statusCode: 400,
                                        error: nil)
        } catch {
            XCTFail(error.localizedDescription)
        }
            
        let expectation = expectation(description: "Fetch auth response")
            
        var accessToken: String?
        var fetchError: Error?
        
        api.getAccessToken()
            .subscribe { validAccessToken in
                accessToken = validAccessToken
                expectation.fulfill()
            } onError: { error in
                fetchError = error
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        
        waitForExpectations(timeout: 3.0)
        
        XCTAssertEqual(accessToken, cachedToken)
        XCTAssertNil(fetchError)
    }
    
    func testFetchAccessToken() {
        AuthManager.shared.eraseData()
        do {
            try URLProtocolStub.setStub(for: api.fullUrl(for: .authentication),
                                        mockType: AuthResponse.self,
                                        statusCode: 200,
                                        error: nil)
        } catch {
            XCTFail(error.localizedDescription)
        }
            
        let expectation = expectation(description: "Fetch auth response")
            
        var accessToken: String?
        var fetchError: Error?
        
        api.getAccessToken()
            .subscribe { validAccessToken in
                accessToken = validAccessToken
                expectation.fulfill()
            } onError: { error in
                fetchError = error
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        
        waitForExpectations(timeout: 3.0)
        
        XCTAssertEqual(accessToken, "mock token")
        XCTAssertNil(fetchError)
    }
    
    func testGetAnimals() {
        do {
            try URLProtocolStub.setStub(for: api.fullUrl(for: .authentication),
                                        mockType: AuthResponse.self,
                                        statusCode: 200,
                                        error: nil)
            
            try URLProtocolStub.setStub(for: api.fullUrl(for: .animals),
                                        mockType: AnimalResponse.self,
                                        statusCode: 200,
                                        error: nil)
        } catch {
            XCTFail(error.localizedDescription)
        }
            
        let expectation = expectation(description: "Fetch animals")
            
        
        var fetchedAnimals: AnimalResponse?
        var fetchError: Error?
        
        api.getAnimals(type: "dog", page: 0)
            .subscribe { animals in
                fetchedAnimals = animals
                expectation.fulfill()
            } onError: { error in
                fetchError = error
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        
        waitForExpectations(timeout: 3.0)
        
        XCTAssertNotNil(fetchedAnimals, "Failed to fetch animals")
        XCTAssertNil(fetchError)
    }
    
}
