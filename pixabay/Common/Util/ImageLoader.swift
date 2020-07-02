//
//  ImageLoader.swift
//  pixabay
//
//  Created by Xuwei Liang on 2/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

class ImageLoader {
    
    static let shared = ImageLoader()
    var queue = OperationQueue()
    private init() {
        // limit the amount of concurrent operation to 1 for simplicity 
        queue.name = "ImageLoaderQueue"
        queue.maxConcurrentOperationCount = 1
    }
    
    func loadImage(from urlString: String, completionHandler: @escaping (UIImage?)->Void) {
       
        /// check with ImageCache first
        let cachedImage = ImageCache.shared.loadImage(by: urlString)
        if cachedImage != nil {
            completionHandler(cachedImage)
            return
        }
        
        /// otherwise we fetch from url
        guard let url = URL(string: urlString) else { return }
        let session: URLSession = URLSession(configuration: .default)
        ImageCache.shared.printInfo()
        let dataTask = session.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { completionHandler(nil); return }
            ImageCache.shared.cacheImage(by: urlString, image: image)
            completionHandler(image)
            
        }
        dataTask.resume()
    }
}
