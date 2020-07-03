//
//  ImageCache.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import Foundation
import UIKit

/// O(1) to update through circular indexing
/// O(1) to lookup by map
class ImageDictionaryCache: ImageCacheProtocol {
    
    private let cacheSize = 100
    private var history = [String]()
    private var imageCache = Dictionary<String, UIImage>()
    private var nextIndexToAdd = 0
    
    /// we use same queue for updating operations
    /// to ensure operations on imageCache is serially through one queue, enabling transactional update on cache
    private let serialQueue = DispatchQueue(label: "ImageDictionaryCache")
    
    init() {
        /// reserving capacity minimalise the need of memory re-allocation
        imageCache.reserveCapacity(cacheSize)
        history.reserveCapacity(cacheSize)
    }
    
    func cacheImage(by key: String, image: UIImage, completionHandler: @escaping (()->Void)) {
        /// whenever we update our cache, pass it through serialQueue
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            self.addNew(key, image)
            completionHandler()
        }
    }
    
    /// clear method to reset the cache
    /// handy when we want to free up memory in low memory conditions
    func clear(_ completionHandler: (()->Void)?) {
        serialQueue.async {
            self.nextIndexToAdd = 0
            self.imageCache.removeAll()
            self.history.removeAll()
            guard let completion = completionHandler else { return }
            completion()
        }
    }
    
    /// load image from cache if it exist
    func loadImage(by key: String)->UIImage? {
        guard let image = imageCache[key] else { return nil }
        return image
    }
    
    /// adding new image to cache
    private func addNew(_ key: String, _ image: UIImage) {
        
        /// checking if image to be add already exist first
        if loadImage(by: key) != nil { return }
        
        /// condition where cache is not filled up yet, so we just append to history
        if history.count < cacheSize {
            history.append(key)
            imageCache[key] = image
        } else {
            let keyToBeReplaced = history[nextIndexToAdd]
            imageCache.removeValue(forKey: keyToBeReplaced)
            history[nextIndexToAdd] = key
        }
        imageCache[key] = image
        
        /// using circular indexing strategy to re-use oldest slots for caching once we filled up cache 
        nextIndexToAdd = (nextIndexToAdd + 1) % cacheSize
    }
}

/// helper methods for debugging, not essential for implementation
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
    /// mod of cacheSize to get the index of item before "nextIndexToAdd"
    private func newestKeyIndex()->Int {
        /// before history reaches cacheSize, we just return whatever is last index by size of history
        if nextIndexToAdd >= history.count { return history.count - 1 }
        let currentNewestIndex = ((nextIndexToAdd - 1) + cacheSize) % cacheSize
        return currentNewestIndex
    }
}
