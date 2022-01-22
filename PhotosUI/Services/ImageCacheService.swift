//
//  ImageCacheService.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/22.
//

import UIKit
import Combine

enum CacheError: Error, CustomStringConvertible {
    case invalidImage
    case failureDiskStore
    
    var description: String {
        switch self {
        case .invalidImage:
            return "CacheError: invalidImage"
        case .failureDiskStore:
            return "CacheError: failureDiskStore"
        }
    }
}

protocol ImageCacheServiceProtocol {
    
    func cacheImage(urlStr: String,
                    image: UIImage)
    -> AnyPublisher<Result<UIImage, Error>, Error>
    
    func fetchCachedImage(urlStr: String)
    -> AnyPublisher<Result<UIImage?, Error>, Error>
    
}

class ImageCacheService: ImageCacheServiceProtocol {
    
    var provider: ManagerProviderProtocol
    
    init(provider: ManagerProviderProtocol) {
        self.provider = provider
    }
    
    func cacheImage(urlStr: String,
                    image: UIImage)
    -> AnyPublisher<Result<UIImage, Error>, Error> {
        let key = urlStr.removeSpecialCharsFromString()
        return Future.init { [weak self] promise in
            guard let `self` = self else { return }
            self.provider
                .memoryCacheManager
                .store(key: key,
                       image: image)
            guard let data = image.pngData() else {
                promise(.failure(CacheError.invalidImage))
                return
            }
            _ = self.provider
                .diskCacheManager
                .storeIfNeed(key: key,
                             data: data)
            promise(.success(.success(image)))
        }.eraseToAnyPublisher()
    }
    
    func fetchCachedImage(urlStr: String)
    -> AnyPublisher<Result<UIImage?, Error>, Error> {
        let key = urlStr.removeSpecialCharsFromString()
        return Future.init { [weak self] promise in
            guard let `self` = self else { return }
            if let cachedImg = self.provider
                .memoryCacheManager
                .fetch(key: key) {
                promise(.success(.success(cachedImg)))
            } else if let cachedData = self.provider
                        .diskCacheManager
                        .fetch(key: key),
                      let cachedImg = UIImage(data: cachedData) {
                self.provider
                    .memoryCacheManager
                    .store(key: key, image: cachedImg)
                promise(.success(.success(cachedImg)))
            } else {
                promise(.success(.success(nil)))
            }
        }.eraseToAnyPublisher()
    }
    
}
