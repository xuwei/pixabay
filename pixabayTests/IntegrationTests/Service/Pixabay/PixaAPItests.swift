//
//  PixaAPItests.swift
//  pixabayTests
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import XCTest
@testable import pixabay

class PixaAPItests: XCTestCase {
    
    let defaultPageSize = 50
    let defaultPageNo = 1
    let defaultKeyword = "beers"

    func testSearchWithNoText() {
        let expectation = XCTestExpectation(description: "testSearchWithNoText")
        let req = PixaAPISearchReq(keywords: "", pageSize: defaultPageSize, pageNo: defaultPageNo)
        PixaAPI.shared.search(req) { result in
            XCTAssertNotNil(result)
            switch result {
                case .success:
                    XCTFail()
                case .failure(let err):
                    // ensure we get invalid params error
                    XCTAssertTrue(err == PixaAPIError.invalidParams)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: XCTestConfig.shared.integrationTestTimeout)
    }
    
    func testSearchWithText() {
        let expectation = XCTestExpectation(description: "testSearchWithText")
        let req = PixaAPISearchReq(keywords: defaultKeyword, pageSize: defaultPageSize, pageNo: defaultPageNo)
        PixaAPI.shared.search(req) { result in
            switch result {
            case .success(let searchResult):
                XCTAssertNotNil(searchResult)
                XCTAssertTrue(searchResult.images.count == self.defaultPageSize)
                for image in searchResult.images {
                    XCTAssertNotNil(image)
                    XCTAssertTrue(!image.tags.isEmpty)
                    XCTAssertTrue(!image.user.isEmpty)
                    XCTAssertTrue(!image.webformatURL.isEmpty)
                }
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: XCTestConfig.shared.integrationTestTimeout)
    }

    func testSearchWithEmptySearchResults() {
        let expectation = XCTestExpectation(description: "testSearchWithEmptySearchResults")
        // some keyword that would return empty results
        let keywords = "_________"
        let req = PixaAPISearchReq(keywords: keywords, pageSize: defaultPageSize, pageNo: defaultPageNo)
        PixaAPI.shared.search(req) { result in
            switch result {
            case .success(let searchResult):
                XCTAssertNotNil(searchResult)
                XCTAssertTrue(searchResult.images.count == 0)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: XCTestConfig.shared.integrationTestTimeout)
    }

    // to ensure changing pagination parameter doesn't return same content
    func testSearchWithPaginations() {
        var searchResultList: [Int: PixaSearchResultModel?] = [:]
        let req1 = PixaAPISearchReq(keywords: defaultKeyword, pageSize: defaultPageSize, pageNo: defaultPageNo)
        let req2 = PixaAPISearchReq(keywords: defaultKeyword, pageSize: defaultPageSize, pageNo: defaultPageNo + 1)
        
        let waitingGroup = DispatchGroup()
        for (index, req) in [req1, req2].enumerated() {
            waitingGroup.enter()
            PixaAPI.shared.search(req) { result in
                switch result {
                case .success(let searchResult):
                    XCTAssertNotNil(searchResult)
                    searchResultList[index] = searchResult
                case .failure:
                    XCTFail()
                }
                waitingGroup.leave()
            }
        }
        waitingGroup.wait()
        
        guard let result1 = searchResultList[0] as? PixaSearchResultModel else { XCTFail(); return }
        guard let result2 = searchResultList[1] as? PixaSearchResultModel else { XCTFail(); return }
        XCTAssertNotNil(result1.images)
        XCTAssertNotNil(result2.images)
        XCTAssertTrue(result1.images.count > 0)
        XCTAssertTrue(result2.images.count > 0)
        let image1: PixaImageModel = result1.images[0]
        let image2: PixaImageModel = result2.images[0]
        XCTAssertFalse(image1 == image2)
    }

    // ensure if we can handle special characters
    func testSearchWithPaginationsWithSpecialCharacters() {
        let expectation = XCTestExpectation(description: "testSearchWithNoText")
        let req = PixaAPISearchReq(keywords: "#$%^&*()!", pageSize: defaultPageSize, pageNo: defaultPageNo)
        PixaAPI.shared.search(req) { result in
            switch result {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertTrue(result.maxImagesPerQuery == 0)
                XCTAssertTrue(result.total == 0)
                XCTAssertTrue(result.images.count == 0)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
            
        }
        
        wait(for: [expectation], timeout: XCTestConfig.shared.integrationTestTimeout)
    }


}
