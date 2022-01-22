//
//  MockImageLoadService.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import Foundation
import UIKit
import Combine
@testable import PhotosUI

class MockImageLoadService: ImageLoadServiceProtocol {
    
    var model: PhotoModel?
    var downloadImageResultParam: Result<(PhotoModel, UIImage?), Error>?
    var cacheImageResultParam: Result<(PhotoModel, UIImage), Error>?
    
    func fetchCachedImage(_ model: PhotoModel) -> AnyPublisher<Result<(PhotoModel, UIImage?), Error>, Error> {
        self.model = model
        return Future.init { promise in
            promise(.success(.success((model, nil))))
        }.eraseToAnyPublisher()
    }
    
    func downloadImage(_ result: Result<(PhotoModel, UIImage?), Error>) -> AnyPublisher<Result<(PhotoModel, UIImage), Error>, Error> {
        self.downloadImageResultParam = result
        return Future.init { _ in
        }.eraseToAnyPublisher()
    }
    
    func cacheImage(_ result: Result<(PhotoModel, UIImage), Error>) -> AnyPublisher<Result<(PhotoModel, UIImage), Error>, Error> {
        self.cacheImageResultParam = result
        return Future.init { _ in
        }.eraseToAnyPublisher()
    }
    
}
