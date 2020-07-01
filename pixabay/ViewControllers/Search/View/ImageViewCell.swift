//
//  ImageViewCell.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

class ImageViewCell: BaseTableViewCell {
    
    static var cellIdentifier: String = "ImageViewCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var tags: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellImage.layer.cornerRadius = 4.0
    }
    
    override func setupUI(_ viewModel: BaseTableViewModelProtocol) {
        let vm = viewModel as! ImageViewCellViewModel
        user.text = vm.user
        tags.text = vm.tags
        cellImage.loadImage(from: vm.imageUrl) { [weak self] image in
            guard let self = self else { return }
            guard let image = image else { return }
            DispatchQueue.main.async {
                self.cellImage.image = image
            }
        }
    }
}
