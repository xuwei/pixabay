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
    
    /// keeping maximum of 3 concurrent task in queue
    private let maxConcurrentReq = 3
    private let cache: ImageCacheProtocol = ImageDictionaryCache()
    private var imageLoaderSession: URLSession?
    private var imageLoaderOperationQueue = OperationQueue()
    
    private init() {
        imageLoaderOperationQueue.maxConcurrentOperationCount = maxConcurrentReq
        imageLoaderOperationQueue.qualityOfService = .utility
        imageLoaderSession = URLSession(configuration: .default, delegate: nil, delegateQueue: imageLoaderOperationQueue)
    }
    
    func loadImage(from urlString: String, completionHandler: @escaping (UIImage?)->Void) {
       
        /// check with ImageCache first
        let cachedImage = cache.loadImage(by: urlString)
        if cachedImage != nil {
            completionHandler(cachedImage)
            return
        }
        /// otherwise we fetch from url
        guard let url = URL(string: urlString) else { return }
        
        /// dataTask is function variable, will get discarded
        let dataTask = imageLoaderSession?.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { completionHandler(nil); return }
            
            /// make sure caching is completed before completing
            self.cache.cacheImage(by: urlString, image: image) {
                completionHandler(image)
            }
        }
        
        dataTask?.resume()
    }
}
