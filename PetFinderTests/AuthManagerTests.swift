//
//  AuthManagerTests.swift
//  AuthManagerTests
//
//  Created by Iustin Bulimar on 20.10.2023.
//

import XCTest

@testable import PetFinder

final class AuthManagerTests: XCTestCase {
    
    var authManager = AuthManager.shared

    override func setUpWithError() throws {
        super.setUp()
        authManager.reloadData()
    }

    override func tearDownWithError() throws {
        authManager.eraseData()
        try super.tearDownWithError()
    }

    func testValidToken() throws {
        let token = "token"
        let expiresIn: TimeInterval = 2
        let expectation = expectation(description: "Wait for token to almost expire")
        
        authManager.update(token: token, expiresIn: expiresIn)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + expiresIn - 1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        XCTAssertEqual(token, authManager.validAccessToken)
    }
    
    func testExpiredToken() throws {
        let token = "token"
        let expiresIn: TimeInterval = 1
        let expectation = expectation(description: "Wait for token to expire")
        
        authManager.update(token: token, expiresIn: expiresIn)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + expiresIn) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        XCTAssertNil(authManager.validAccessToken)
    }
    
    func testTokenPersistence() throws {
        let token = "token"
        let expiresIn: TimeInterval = 1
        
        authManager.update(token: token, expiresIn: expiresIn)
        
        authManager.reloadData()
        
        XCTAssertEqual(token, authManager.validAccessToken)
    }
    
    func testTokenReset() throws {
        let token = "token"
        let expiresIn: TimeInterval = 1
        
        authManager.update(token: token, expiresIn: expiresIn)
        
        authManager.eraseData()
        authManager.reloadData()
        
        XCTAssertNil(authManager.validAccessToken)
    }
    
}
