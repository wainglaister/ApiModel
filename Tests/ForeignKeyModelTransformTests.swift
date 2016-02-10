//
//  ModelTransformTests.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 2016-20-01.
//
//

import XCTest
import ApiModel
import RealmSwift

class ForeignKeyModelTransformTests: XCTestCase {
    
    var realm: Realm!
    var postTransform: ForeignKeyModelTransform<Post>!
    
    override func setUp() {
        try! realm = Realm()
        postTransform = ForeignKeyModelTransform<Post>()
    }
    
    override func tearDown() {
        if let path = realm.configuration.path {
            try! NSFileManager.defaultManager().removeItemAtPath(path)
        }
    }
    
    func testSimpleConversion() {
        let response = 1
        
        let post = postTransform.perform(response, realm: nil) as? Post
        
        XCTAssertEqual(post?.id, "1")
    }

    func testConversionIntoPersistedObject() {
        // Create a persisted object
        let persistedPost = Post()
        persistedPost.id = "1337"
        persistedPost.title = "Hello world"
        
        try! realm.write {
            self.realm.add(persistedPost, update: true)
        }
        
        let response = "1337"
        
        try! realm.write {
            let otherPost = postTransform.perform(response, realm: realm) as! Post
            
            XCTAssertEqual(otherPost.id, "1337")
            XCTAssertEqual(otherPost.title, "Hello world")
            
            XCTAssertEqual(persistedPost.title, "Hello world")
        }
    }
}
