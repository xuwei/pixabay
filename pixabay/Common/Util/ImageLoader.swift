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
    let cache: ImageCacheProtocol = ImageDictionaryCache()
    private init() { }
    
    func loadImage(from urlString: String, completionHandler: @escaping (UIImage?)->Void) {
       
        /// check with ImageCache first
        let cachedImage = cache.loadImage(by: urlString)
        if cachedImage != nil {
            completionHandler(cachedImage)
            return
        }
        
        
        self.cache.printInfo()
        /// otherwise we fetch from url
        guard let url = URL(string: urlString) else { return }
        let session: URLSession = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { completionHandler(nil); return }
            
            /// make sure caching is completed before completing
            self.cache.cacheImage(by: urlString, image: image) {
                completionHandler(image)
            }
            
        }
        dataTask.resume()
    }
}
