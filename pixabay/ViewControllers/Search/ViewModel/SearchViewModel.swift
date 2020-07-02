//
//  SearchViewModel.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

class SearchViewModel {
    
    let title = ScreenName.search.rawValue
    var data: [ImageViewCellViewModel] = []
    let pageSize = 50
    var pageNo = 1
    var total = 0
    var numOfPages = 0
    var prevKeyword = ""
    
    /// closure for array map to transform PixaImageModel to cell models
    private let transformToCellViewModel: ((PixaImageModel)-> ImageViewCellViewModel) = { model in
        return ImageViewCellViewModel(imageUrl: model.webformatURL, user: model.user, tags: model.tags)
    }
    
    func loadMore(_ completionHandler: @escaping ((Result<[ImageViewCellViewModel], PixaAPIError>)->Void)) {
        guard isLastPage() == false else { return }
        pageNo = pageNo + 1
        let searchReq = PixaAPISearchReq(keywords: prevKeyword, pageSize: pageSize, pageNo: pageNo)
        PixaAPI.shared.search(searchReq) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let searchResult):
                let newData = searchResult.images.map(self.transformToCellViewModel)
                self.data = self.data + newData
                completionHandler(.success(self.data))
            case .failure(let err):
                completionHandler(.failure(err))
            }
        }
    }
    
    // search method leveraging on PixaAPI
    func search(_ keyword: String,
                _ completionHandler: @escaping ((Result<(Void),PixaAPIError>)->Void)) {
        
        if keyword.isEmpty { clear(); completionHandler(.success(())); return }
        if isSameKeyword(keyword) { completionHandler(.success(())); return }
        prevKeyword = keyword
        let searchReq = PixaAPISearchReq(keywords: keyword, pageSize: pageSize, pageNo: pageNo)
        PixaAPI.shared.search(searchReq) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let searchResult):
                self.total = searchResult.total
                self.numOfPages = self.calcTotalPages(total: self.total, pageSize: self.pageSize)
                self.data = searchResult.images.map(self.transformToCellViewModel)
                completionHandler(.success(()))
            case .failure(let err):
                completionHandler(.failure(err))
            }
        }
    }
}

// private methods
extension SearchViewModel {
    /// if user clears the search bar, we use this method to clear the photos
    private func clear() {
        data = []
        /// reseting query values
        pageNo = 1
        prevKeyword = ""
        total = 0
        numOfPages = 0
    }
    
    /// if user didn't change the search bar text, we don't need to search again
    private func isSameKeyword(_ keyword: String)->Bool {
        return prevKeyword == keyword ? true : false
    }
    
    /// calculate total number of pages needed
    func calcTotalPages(total: Int, pageSize: Int)->Int {
        guard pageSize > 0 else { return 0 }
        guard total > 0 else { return 0 }
        
        let remainingPage = (total % pageSize == 0) ? 0 : 1
        // calculate total number of pages we need to cover the total
        let numOfPages = total / pageSize + remainingPage
        return numOfPages
    }
    
    
    /// check if we are at last page
    private func isLastPage()-> Bool {
       return pageNo == numOfPages ? true : false
    }
       
    /// helper method to validate conditions for incrementing page
    func needMore(for index: Int)-> Bool {
        if index >= total { return false }
        return index >= (self.data.count - 1) ? true : false
    }
}
