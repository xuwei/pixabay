//
//  SearchViewModelTests.swift
//  pixabayTests
//
//  Created by Xuwei Liang on 2/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import XCTest
@testable import pixabay

class SearchViewModelTests: XCTestCase {

    func testCalculateLastPageInvalid() {
        let viewModel = SearchViewModel()
        
        let result = viewModel.calcTotalPages(total: 0, pageSize: 25)
        XCTAssertTrue(result == 0)
        
        let result2 = viewModel.calcTotalPages(total: 100, pageSize: 0)
        XCTAssertTrue(result2 == 0)
    }
    
    func testCalculateLastPage() {
        let viewModel = SearchViewModel()
        
        let result = viewModel.calcTotalPages(total: 100, pageSize: 25)
        XCTAssertTrue(result == 4)
        
        let result2 = viewModel.calcTotalPages(total: 101, pageSize: 25)
        XCTAssertTrue(result2 == 5)
    }
}
