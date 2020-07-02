//
//  ImageCache.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import Foundation
import UIKit

/// O(1) to remove oldest using circular queue indexing
/// O(1) to insert
/// O(1) to lookup by map
class ImageDictionaryCache: ImageCacheProtocol {
    
    private let cacheSize = 100
    private var history = [String]()
    private var imageCache = Dictionary<String, UIImage>()
    private var nextIndexToAdd = 0
    
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
            self.addNew(key, image)
            completionHandler()
        }
    }
    
    /// helper method to return which key is oldest
    func oldestKey()-> String {
        if history.isEmpty { return "" }
        if nextIndexToAdd >= history.count { return history[0] }
        /// oldest key is next to be replace
        return history[nextIndexToAdd]
    }
    
    /// return key of the newest item
    func newestKey()->String {
        let index = newestKeyIndex()
        return history[index]
    }
    
    /// newestIndex + cacheSize to avoid negative number when we minus 1
    /// through mod of cacheSize, we will get the right index before "nextIndexToAdd" in our circular queue indexing
    private func newestKeyIndex()->Int {
        if nextIndexToAdd >= history.count { return history.count - 1 }
        let currentNewestIndex = ((nextIndexToAdd - 1) + cacheSize) % cacheSize
        return currentNewestIndex
    }
    
    /// to reset the cache
    func clear(_ completionHandler: (()->Void)?) {
        queue.async {
            self.nextIndexToAdd = 0
            self.imageCache.removeAll()
            self.history.removeAll()
            guard let completion = completionHandler else { return }
            completion()
        }
    }
    
    /// load image from cache
    func loadImage(by key: String)->UIImage? {
        guard let image = imageCache[key] else { return nil }
        return image
    }
    
    /// whenever we have new image to cache, we use this method
    private func addNew(_ key: String, _ image: UIImage) {
        if loadImage(by: key) != nil { return }
        if history.count < cacheSize {
            history.append(key)
            imageCache[key] = image
        } else {
            let keyToBeReplaced = history[nextIndexToAdd]
            imageCache.removeValue(forKey: keyToBeReplaced)
            history[nextIndexToAdd] = key
        }
        imageCache[key] = image
        nextIndexToAdd = (nextIndexToAdd + 1) % cacheSize
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
