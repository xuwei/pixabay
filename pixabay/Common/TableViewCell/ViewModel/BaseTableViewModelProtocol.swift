//
//  BaseTableViewModel.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

/// protocol to add identifier variable to cell model, convenient for dequeueing 
protocol BaseTableViewModelProtocol {
    var identifier: String { get }
}
