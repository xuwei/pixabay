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
    
    init() {
        imageCache.reserveCapacity(cacheSize)
        history.reserveCapacity(cacheSize)
    }
    
    func cacheImage(by key: String, image: UIImage) {
        if imageCache.count == cacheSize {
            /// once cacheSize have reached, we start removing oldest as we add new
            removeOldest()
            addNew(key, image)
        } else {
            /// before the cacheSize is filled up, we simply add new
            addNew(key, image)
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
    func clear() {
        oldestIndex = 0
        nextIndexToAdd = 0
        imageCache = [String: UIImage]()
        history = [String]()
        imageCache.reserveCapacity(cacheSize)
        history.reserveCapacity(cacheSize)
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
