//
//  BaseTableViewCell.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

/// protocol to give tableviewcell a method to setup UI by model 
class BaseTableViewCell: UITableViewCell {
    func setupUI(_ viewModel: BaseTableViewModelProtocol) { }
}
