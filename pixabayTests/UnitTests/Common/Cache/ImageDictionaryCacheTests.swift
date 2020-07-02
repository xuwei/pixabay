//
//  ImageCacheTest.swift
//  pixabayTests
//
//  Created by Xuwei Liang on 2/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import XCTest
@testable import pixabay

class ImageDictionaryCacheTests: XCTestCase {

    func testCachingEmpty() {
        let cache = ImageDictionaryCache()
        cache.printInfo()
        XCTAssertTrue(cache.oldestKey() == "")
    }
    
    func testCachingLessThanMax() {
        let cache = ImageDictionaryCache()
        let group = DispatchGroup()
        for key in 0..<50 {
            group.enter()
            cache.cacheImage(by: String(key), image: UIImage()) {
                group.leave()
            }
        }
        group.wait()
        cache.printInfo()
        let oldestKey = cache.oldestKey()
        let newestKey = cache.newestKey()
        XCTAssertTrue(oldestKey == "0")
        XCTAssertTrue(newestKey == "49")
        XCTAssertTrue(cache.imageCacheSize() == 50)
        XCTAssertTrue(cache.historySize() == 50)
        
    }
    
    func testCachingMoreThanMax() {
        let cache = ImageDictionaryCache()
        let group = DispatchGroup()
        for key in 0..<101 {
            group.enter()
            cache.cacheImage(by: String(key), image: UIImage()) {
                group.leave()
            }
        }
        group.wait()
        cache.printInfo()
        let oldestKey = cache.oldestKey()
        let newestKey = cache.newestKey()
        XCTAssertTrue(oldestKey == "1")
        XCTAssertTrue(newestKey == "100")
        XCTAssertTrue(cache.imageCacheSize() == 100)
        XCTAssertTrue(cache.historySize() == 100)
    }
    
    func testCachingMoreThanMax2() {
        let cache = ImageDictionaryCache()
        let group = DispatchGroup()
        for i in 0..<200 {
            group.enter()
            cache.cacheImage(by: String(i), image: UIImage()) {
                 group.leave()
            }
        }
        group.wait()
        cache.printInfo()
        let oldestKey = cache.oldestKey()
        XCTAssertTrue(oldestKey == "100")
        XCTAssertTrue(cache.newestKey() == "199")
        XCTAssertTrue(cache.imageCacheSize() == 100)
        XCTAssertTrue(cache.historySize() == 100)
    }
    
    func testCachingMoreThanMax3() {
        let cache = ImageDictionaryCache()
        let group = DispatchGroup()
        for i in 0..<1000 {
            group.enter()
            cache.cacheImage(by: String(i), image: UIImage()) {
                group.leave()
            }
        }
        group.wait()
        cache.printInfo()
        let oldestKey = cache.oldestKey()
        XCTAssertTrue(oldestKey == "900")
        XCTAssertTrue(cache.newestKey() == "999")
        XCTAssertTrue(cache.imageCacheSize() == 100)
        XCTAssertTrue(cache.historySize() == 100)
    }
    
    func testCacheClear() {
        let expectation = XCTestExpectation(description: "testCacheClear")
        let cache = ImageDictionaryCache()
        let group = DispatchGroup()
        for i in 0..<999 {
            group.enter()
            cache.cacheImage(by: String(i), image: UIImage()) {
                group.leave()
            }
        }
        group.wait()
        cache.clear() {
            let oldestKey = cache.oldestKey()
            XCTAssertTrue(oldestKey == "")
            XCTAssertTrue(cache.imageCacheSize() == 0)
            XCTAssertTrue(cache.historySize() == 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: XCTestConfig.shared.unitTestTimeout)
    }
    
    func testLoadInvalidKey() {
        let cache = ImageDictionaryCache()
        let result = cache.loadImage(by: "")
        XCTAssertNil(result)
        XCTAssertTrue(cache.imageCacheSize() == 0)
        XCTAssertTrue(cache.historySize() == 0)
    }
    
    func testLoadInvalidKey2() {
        let cache = ImageDictionaryCache()
        let group = DispatchGroup()
        for i in 0..<50 {
            group.enter()
            cache.cacheImage(by: String(i), image: UIImage()) {
                group.leave()
            }
        }
        group.wait()
        
        let result = cache.loadImage(by: "51")
        XCTAssertNil(result)
        XCTAssertTrue(cache.imageCacheSize() == 50)
        XCTAssertTrue(cache.historySize() == 50)
    }
    
    /// in case of concurrently caching, the key sequence cached would not be exactly sequential
    /// but mostly on the 9900-10000 range
    func testConcurrentCaching() {
        let cache = ImageDictionaryCache()
        // Do any additional setup after loading the view, typically from a nib.
        let group = DispatchGroup()
        DispatchQueue.concurrentPerform(iterations: 10000) { index in
            group.enter()
            cache.cacheImage(by: String(index), image: UIImage()) {
                group.leave()
            }
            
        }
        
        group.wait()
        
        cache.printInfo()
        XCTAssertTrue(cache.imageCacheSize() == 100)
        XCTAssertTrue(cache.historySize() == 100)
    }
}
