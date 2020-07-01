//
//  SearchViewModel.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

class SearchViewModel {
    
    func needMore(for _: Int)-> Bool {
        return false
    }
    
    func loadMore(_ completionHandler: (()->Void)?) {
        guard let completion = completionHandler else { return }
        completion()
    }
}
