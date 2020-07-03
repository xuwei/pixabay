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
    
    /// keeping maximum of 4 concurrent task in queue
    private let maxConcurrentReq = 4
    private let cache: ImageCacheProtocol = ImageDictionaryCache()
    private var imageLoaderSession: URLSession?
    private var imageLoaderOperationQueue = OperationQueue()
    
    private init() {
        imageLoaderOperationQueue.maxConcurrentOperationCount = maxConcurrentReq
        imageLoaderOperationQueue.qualityOfService = .utility
        imageLoaderSession = URLSession(configuration: .default, delegate: nil, delegateQueue: imageLoaderOperationQueue)
    }
    
    func clearCache() {
        cache.clear {}
    }
    
    func loadImage(from urlString: String, completionHandler: @escaping (UIImage?)->Void) {
       
        /// check if url is valid
        guard let url = URL(string: urlString) else { completionHandler(nil); return }
        
        /// check with image is cached first
        if let cachedImage = cache.loadImage(by: urlString) { completionHandler(cachedImage); return }
        
        /// dataTask is function variable, will get discarded automatically
        let dataTask = imageLoaderSession?.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { completionHandler(nil); return }
            guard let data = data else { completionHandler(nil); return }
            guard let image = UIImage(data: data) else { completionHandler(nil); return }
            
            /// return image after caching is completed
            self.cache.cacheImage(by: urlString, image: image) {
                completionHandler(image)
            }
        }
        
        dataTask?.resume()
    }
}
