//
//  PixabaySearchResultModel.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

struct PixaSearchResultModel: Codable {
    let total: Int
    let maxImagesPerQuery: Int
    let images: [PixaImageModel]
    
    private enum CodingKeys: String, CodingKey {
        case total = "total"
        case maxImagesPerQuery = "totalHits"
        case images = "hits"
    }
}
