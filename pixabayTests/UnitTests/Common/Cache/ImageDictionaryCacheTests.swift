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
        for key in 0..<50 {
            cache.cacheImage(by: String(key), image: UIImage())
        }
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
        for key in 0..<101 {
            cache.cacheImage(by: String(key), image: UIImage())
        }
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
        for i in 0..<200 {
            cache.cacheImage(by: String(i), image: UIImage())
        }
        cache.printInfo()
        let oldestKey = cache.oldestKey()
        XCTAssertTrue(oldestKey == "100")
        XCTAssertTrue(cache.newestKey() == "199")
        XCTAssertTrue(cache.imageCacheSize() == 100)
        XCTAssertTrue(cache.historySize() == 100)
    }
    
    func testCachingMoreThanMax3() {
        let cache = ImageDictionaryCache()
        for i in 0..<1000 {
            cache.cacheImage(by: String(i), image: UIImage())
        }
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
        for i in 0..<999 {
            cache.cacheImage(by: String(i), image: UIImage())
        }
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
        for i in 0..<50 {
            cache.cacheImage(by: String(i), image: UIImage())
        }
        let result = cache.loadImage(by: "51")
        XCTAssertNil(result)
        XCTAssertTrue(cache.imageCacheSize() == 50)
        XCTAssertTrue(cache.historySize() == 50)
    }
}
