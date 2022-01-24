//
//  MemoryCacheManager.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/22.
//

import Foundation
import UIKit

protocol MemoryCacheManagerProtocol {
    
    /// Store image to the memory cache with key
    func store(key: String, image: UIImage)
    
    /// Fetch image from the memory cache with key
    func fetch(key: String) -> UIImage?
    
}

class MemoryCacheManager: MemoryCacheManagerProtocol {
    
    private let imageCache: NSCache<NSString, UIImage>
    
    init(cacheManager: NSCache<NSString, UIImage>) {
        self.imageCache = cacheManager
    }
    
    func store(key: String, image: UIImage) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    func fetch(key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
}
