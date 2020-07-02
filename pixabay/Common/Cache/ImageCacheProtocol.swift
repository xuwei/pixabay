//
//  ImageCacheProtocol.swift
//  pixabay
//
//  Created by Xuwei Liang on 2/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

protocol ImageCacheProtocol {
    func cacheImage(by key: String, image: UIImage, completionHandler: @escaping (()-> Void))
    func loadImage(by key: String)->UIImage?
    func printInfo()
}
