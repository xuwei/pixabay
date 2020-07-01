//
//  PixabayImageModel.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

struct PixaImageModel: Codable {
    let id: Int
    let tags: String
    let webformatURL: String
    let user: String
}


extension PixaImageModel: Equatable {
    static func == (lhs: PixaImageModel, rhs: PixaImageModel)-> Bool {
        return lhs.id == rhs.id
    }
}
