//
//  ImageViewCellViewModel.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

struct ImageViewCellViewModel: BaseTableViewModelProtocol {
    var identifier: String = ImageViewCell.cellIdentifier
    let imageUrl: String
    let user: String
    let tags: String
}
