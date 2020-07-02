//
//  ImageViewCell.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

class ImageViewCell: UITableViewCell {
    
    static var cellIdentifier: String = "ImageViewCell"
    let cornerRadius: CGFloat = 8.0
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var tags: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellImage.layer.cornerRadius = cornerRadius
    }
    
    func setupUI(_ viewModel: BaseTableViewModelProtocol) {
        let vm = viewModel as! ImageViewCellViewModel
        user.text = vm.user
        tags.text = vm.tags
        
        // reset image before loading from tableviewcontroller 
        cellImage.image = nil
    }
}
