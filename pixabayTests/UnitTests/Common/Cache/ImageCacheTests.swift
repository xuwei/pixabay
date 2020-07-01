//
//  ImageCacheTest.swift
//  pixabayTests
//
//  Created by Xuwei Liang on 2/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import XCTest
@testable import pixabay

class ImageCacheTests: XCTestCase {

    func testCachingEmpty() {
        ImageCache.shared.printInfo()
        XCTAssertTrue(ImageCache.shared.oldestKey() == "")
    }
    
    func testCachingLessThanMax() {
        for key in 0..<50 {
            ImageCache.shared.cacheImage(by: String(key), image: UIImage())
        }
        ImageCache.shared.printInfo()
        let oldestKey = ImageCache.shared.oldestKey()
        let newestKey = ImageCache.shared.newestKey()
        XCTAssertTrue(oldestKey == "0")
        XCTAssertTrue(newestKey == "49")
    }
    
    func testCachingMoreThanMax() {
        for key in 0..<101 {
            ImageCache.shared.cacheImage(by: String(key), image: UIImage())
        }
        ImageCache.shared.printInfo()
        let oldestKey = ImageCache.shared.oldestKey()
        let newestKey = ImageCache.shared.newestKey()
        XCTAssertTrue(oldestKey == "1")
        XCTAssertTrue(newestKey == "100")
    }
    
    func testCachingMoreThanMax2() {
        for i in 0..<200 {
            ImageCache.shared.cacheImage(by: String(i), image: UIImage())
        }
        ImageCache.shared.printInfo()
        let oldestKey = ImageCache.shared.oldestKey()
        XCTAssertTrue(oldestKey == "100")
        XCTAssertTrue(ImageCache.shared.newestKey() == "199")
    }
    
    func testCachingMoreThanMax3() {
        for i in 0..<1000 {
            ImageCache.shared.cacheImage(by: String(i), image: UIImage())
        }
        ImageCache.shared.printInfo()
        let oldestKey = ImageCache.shared.oldestKey()
        XCTAssertTrue(oldestKey == "900")
        XCTAssertTrue(ImageCache.shared.newestKey() == "999")
    }
    
    func testCacheClear() {
        for i in 0..<999 {
            ImageCache.shared.cacheImage(by: String(i), image: UIImage())
        }
        ImageCache.shared.clear()
        let oldestKey = ImageCache.shared.oldestKey()
        XCTAssertTrue(oldestKey == "")
    }
    
    func testLoadInvalidKey() {
        let result = ImageCache.shared.loadImage(by: "")
        XCTAssertNil(result)
    }
    
    func testLoadInvalidKey2() {
        for i in 0..<50 {
            ImageCache.shared.cacheImage(by: String(i), image: UIImage())
        }
        let result = ImageCache.shared.loadImage(by: "51")
        XCTAssertNil(result)
    }
}
