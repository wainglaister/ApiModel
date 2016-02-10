//
//  ApiFormTests.swift
//  APIModel
//
//  Created by Craig Heneveld on 1/14/16.
//
//

import XCTest
import ApiModel
import Alamofire
import OHHTTPStubs
import RealmSwift

class ApiFormTests: XCTestCase {
    var timeout: NSTimeInterval = 10
    var testRealm: Realm!
    var host = "http://you-dont-party.com"
    
    override func setUp() {
        
        super.setUp()
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        
        testRealm = try! Realm()
        
        ApiSingleton.setInstance(ApiManager(config: ApiConfig(host: self.host)))
    }
    
    override func tearDown() {
        
        super.tearDown()
        
        try! testRealm.write {
            self.testRealm.deleteAll()
        }
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testSimpleFindArray() {
        
        var theResponse: [Post]?
        let readyExpectation = self.expectationWithDescription("ready")
        
        stub({_ in true}) { request in
            let stubPath = OHPathForFile("posts.json", self.dynamicType)
            return fixture(stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        Api<Post>.findArray { response in
            theResponse = response
            
            XCTAssertEqual(response.count, 2)
            XCTAssertEqual(response.first!.id, "1")
            XCTAssertEqual(response.last!.id, "2")
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        
        self.waitForExpectationsWithTimeout(self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
    
    func testGetWithServerFailure() {
        
        var theResponse: ApiModelResponse<Post>?
        let readyExpectation = self.expectationWithDescription("ready")
        
        
        stub({_ in true}) { request in
            return OHHTTPStubsResponse(data:"Something went wrong!".dataUsingEncoding(NSUTF8StringEncoding)!, statusCode: 500, headers: nil)
        }
        
        Api<Post>.get("/v1/posts.json") { response in
            theResponse = response
            
            XCTAssertEqual(response.errors!, ["base" : ["An unexpected server error occurred"]])
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }

        self.waitForExpectationsWithTimeout(self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
    
    func testFindArrayWithServerFailure() {
        
        var theResponse: [Post]?
        let readyExpectation = self.expectationWithDescription("ready")
        
        
        stub({_ in true}) { request in
            return OHHTTPStubsResponse(data:"Something went wrong!".dataUsingEncoding(NSUTF8StringEncoding)!, statusCode: 500, headers: nil)
        }
        
        Api<Post>.findArray { response in
            theResponse = response
            
            XCTAssertNotNil(response)
            
            XCTAssertEqual(response.count, 0)
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }

        self.waitForExpectationsWithTimeout(self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
    
    func testFindWithServerFailure() {
        
        let readyExpectation = self.expectationWithDescription("ready")
        
        stub({_ in true}) { request in
            return OHHTTPStubsResponse(data:"Something went wrong!".dataUsingEncoding(NSUTF8StringEncoding)!, statusCode: 500, headers: nil)
        }
        
        Api<Post>.find { response in

            XCTAssertNil(response)
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        self.waitForExpectationsWithTimeout(self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNil(err, "Received data should be nil")
        }
    }
    
    func testSaveWithModelValidationErrors() {
        
        let readyExpectation = self.expectationWithDescription("ready")
        
        stub({_ in true}) { request in
            let stubPath = OHPathForFile("post_with_error.json", self.dynamicType)
            return fixture(stubPath!, status: 422, headers: ["Content-Type":"application/json"])
        }
        
        let post = Post()

        let form = Api<Post>(model: post)
        
        form.save { _ in
            XCTAssertTrue(form.hasErrors)
            
            // But what happened? - the server returned meaningful validations but are lost!
            XCTAssertEqual(form.errorMessages, ["An unexpected server error occurred"])

            readyExpectation.fulfill()
            
            OHHTTPStubs.removeAllStubs()
        }
        
        self.waitForExpectationsWithTimeout(self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNil(err, "Received data should be nil")
        }
    }
    
    func testAddHook() {
        var called = false
        
        let config = ApiConfig(host: self.host)
        config.addHook = { realm, object in
            called = true
            realm?.add(object)
        }
        
        ApiSingleton.setInstance(ApiManager(config: config))
        
        var theResponse: [Post]?
        let readyExpectation = self.expectationWithDescription("ready")
        
        stub({_ in true}) { request in
            let stubPath = OHPathForFile("posts.json", self.dynamicType)
            return fixture(stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        Api<Post>.findArray { response in
            theResponse = response
            
            XCTAssertEqual(response.count, 2)
            XCTAssertEqual(response.first!.id, "1")
            XCTAssertEqual(response.last!.id, "2")
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        
        self.waitForExpectationsWithTimeout(self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
            XCTAssertTrue(called, "The hook should have been called")
        }
    }
}
