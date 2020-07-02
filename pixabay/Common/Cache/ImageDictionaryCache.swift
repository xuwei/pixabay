//
//  ImageCache.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

/// O(1) to remove oldest using circular queue indexing
/// O(1) to insert
/// O(1) to lookup by map
class ImageDictionaryCache: ImageCacheProtocol {
    
    private let cacheSize = 100
    private var history = [String]()
    private var imageCache = [String: UIImage]()
    private var nextIndexToAdd = 0
    private var oldestIndex = 0
    
    /// we use same queue for caching operations
    /// to ensure all operations on imageCache is through one queue
    private let queue = DispatchQueue(label: "ImageDictionaryCache")
    
    init() {
        imageCache.reserveCapacity(cacheSize)
        history.reserveCapacity(cacheSize)
    }
    
    func cacheImage(by key: String, image: UIImage, completionHandler: @escaping (()->Void)) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if self.imageCache.count == self.cacheSize {
                /// once cacheSize have reached, we start removing oldest as we add new
                self.removeOldest()
                self.addNew(key, image)
            } else {
                /// before the cacheSize is filled up, we simply add new
                self.addNew(key, image)
            }
            
            completionHandler()
        }
    }
    
    /// helper method to return which key is oldest
    func oldestKey()-> String {
        if history.isEmpty { return "" }
        return history[oldestIndex]
    }
    
    /// return key of the newest item
    func newestKey()->String {
        return history[newestKeyIndex()]
    }
    
    /// newestIndex + cacheSize to avoid negative number when we minus 1
    /// through mod of cacheSize, we will get the right index before "nextIndexToAdd" in our circular queue indexing
    private func newestKeyIndex()->Int {
        let currentNewestIndex = ((nextIndexToAdd + cacheSize) - 1) % cacheSize
        return currentNewestIndex
    }
    
    /// to reset the cache
    func clear(_ completionHandler: (()->Void)?) {
        queue.async {
            self.oldestIndex = 0
            self.nextIndexToAdd = 0
            self.imageCache.removeAll()
            self.history.removeAll()
            guard let completion = completionHandler else { return }
            completion()
        }
    }
    
    /// load image from cache
    func loadImage(by key: String)->UIImage? {
        return imageCache[key]
    }
       
    /// removes the oldest item from imageCache map
    private func removeOldest() {
        imageCache.removeValue(forKey: oldestKey())
    }
    
    /// whenever we have new image to cache, we use this method
    private func addNew(_ key: String, _ image: UIImage) {
        /// When we filled up the cache size, we start updating both newest index and oldest index
        /// To create a circular queue
        if (history.count == cacheSize) {
            history[nextIndexToAdd] = key
            imageCache[key] = image
            nextIndexToAdd = (nextIndexToAdd + 1) % cacheSize
            oldestIndex = (oldestIndex + 1) % cacheSize
        } else {
            /// before cache is filled up, simply add, oldestIndex remains 0
            history.append(key)
            imageCache[key] = image
            nextIndexToAdd = history.count % cacheSize
        }
    }
}

/// helper methods for debugging
extension ImageDictionaryCache {
    
    func imageCacheSize()->Int {
        return imageCache.count
    }

    func historySize()->Int {
        return history.count
    }

    /// print method for debugging purpose
    func printInfo() {
       print(history)
       print(imageCache)
       print("history count: \(history.count)")
       print("cache items count: \(imageCache.count)")
    }
}
