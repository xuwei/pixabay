//
//  ImageNSCache.swift
//  pixabay
//
//  Created by Xuwei Liang on 2/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

/// ImageNSCache leverages on NSCache instead of Dictionary
/// Added for comparison purpose
class ImageNSCache: ImageCacheProtocol {
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    init(_ cacheSize: Int = 100) {
        imageCache.countLimit = cacheSize
    }
    
    func cacheImage(by key: String, image: UIImage, completionHandler: @escaping (()->Void)) {
        imageCache.setObject(image, forKey: key as NSString)
        completionHandler()
    }
    
    func loadImage(by key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
    
    func clear(_ completionHandler: (()->Void)?) {
        imageCache.removeAllObjects()
    }
    
    func printInfo() {
        print(imageCache.debugDescription)
    }
}
