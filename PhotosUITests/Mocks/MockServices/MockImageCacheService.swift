//
//  MockImageCacheService.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import Foundation
import UIKit
import Combine
@testable import PhotosUI

class MockImageCacheService: ImageCacheServiceProtocol {
    
    var urlStr: String?
    var image: UIImage?
    var key: String?
    
    func cacheImage(urlStr: String, image: UIImage) -> AnyPublisher<Result<UIImage, Error>, Error> {
        self.urlStr = urlStr
        self.image = image
        self.key = urlStr.removeSpecialCharsFromString()
        return Future.init { promise in
            promise(.success(.success(UIImage())))
        }.eraseToAnyPublisher()
    }
    
    func fetchCachedImage(urlStr: String) -> AnyPublisher<Result<UIImage?, Error>, Error> {
        self.urlStr = urlStr
        self.key = urlStr.removeSpecialCharsFromString()
        return Future.init { promise in
            promise(.success(.success(UIImage())))
        }.eraseToAnyPublisher()
    }
    
}
