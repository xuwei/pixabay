//
//  ImageCache.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

class ImageCache {
    
    static let shared = ImageCache()
    private let cacheSize = 100
    private var history = [String]()
    private var imageCache = [String: UIImage]()
    private var newestIndex = -1
    private var oldestIndex = 0
    
    private init() {
        imageCache.reserveCapacity(cacheSize)
        history.reserveCapacity(cacheSize)
    }
    
    func cacheImage(by key: String, image: UIImage) {
        if imageCache.count == cacheSize {
            removeOldest()
            addNew(key, image)
        } else {
            addNew(key, image)
        }
    }
    
    func oldestKey()-> String {
        if history.isEmpty { return "" }
        return history[oldestIndex]
    }
    
    /// newestIndex is for the next item to be added, so we want to move one index back
    func newestKey()->String {
        return history[newestKeyIndex()]
    }
    
    /// newestIndex + cacheSize to avoid -1, we will still get the right index through mod
    private func newestKeyIndex()->Int {
        let currentNewestIndex = ((newestIndex + cacheSize) - 1) % cacheSize
        return currentNewestIndex
    }
    
    func clear() {
        oldestIndex = 0
        newestIndex = -1
        imageCache = [String: UIImage]()
        history = [String]()
        imageCache.reserveCapacity(cacheSize)
        history.reserveCapacity(cacheSize)
    }
    
    func loadImage(by key: String)->UIImage? {
        return imageCache[key]
    }
    
    func printInfo() {
       print(history)
       print(imageCache)
    }
       
    
    private func removeOldest() {
        imageCache.removeValue(forKey: oldestKey())
    }
    
    private func addNew(_ key: String, _ image: UIImage) {
        /// only happens when we filled up the cache size
        if (history.count == cacheSize) {
            history[newestIndex] = key
            imageCache[key] = image
            newestIndex = (newestIndex + 1) % cacheSize
            oldestIndex = (oldestIndex + 1) % cacheSize
        } else {
            history.append(key)
            imageCache[key] = image
            newestIndex = history.count % cacheSize
        }
    }
}
