//
//  ImageLoadService.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/22.
//

import UIKit
import Combine

protocol ImageLoadServiceProtocol {
    
    /// The function component for fetching cached image
    func fetchCachedImage(_ model: PhotoModel)
    -> AnyPublisher<Result<(PhotoModel, UIImage?), Error>, Error>
    
    /// The function component for download image through network
    func downloadImage(_ result: Result<(PhotoModel, UIImage?), Error>)
    -> AnyPublisher<Result<(PhotoModel, UIImage), Error>, Error>
    
    /// The function component for caching image into memory and disk
    func cacheImage(_ result: Result<(PhotoModel, UIImage), Error>)
    -> AnyPublisher<Result<(PhotoModel, UIImage), Error>, Error>
    
}

class ImageLoadService: ImageLoadServiceProtocol {
    
    var photoService: PhotoServiceProtocol?
    var imageCacheServie: ImageCacheServiceProtocol?
    var cancellables: [AnyCancellable] = []
    
    init(photoService: PhotoServiceProtocol,
         imageCacheServie: ImageCacheServiceProtocol) {
        self.photoService = photoService
        self.imageCacheServie = imageCacheServie
    }
    
    func fetchCachedImage(_ model: PhotoModel)
    -> AnyPublisher<Result<(PhotoModel, UIImage?), Error>, Error> {
        return Future.init { [weak self] promise in
            guard let `self` = self,
                  let urlStr = model.urls.small else { return }
            _ = self.imageCacheServie?
                .fetchCachedImage(urlStr: urlStr)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { result in
                    guard case let .success(image) = result else {
                        return
                    }
                    promise(.success(.success((model, image))))
                })
            
        }.eraseToAnyPublisher()
    }
    
    func downloadImage(_ result: Result<(PhotoModel, UIImage?), Error>)
    -> AnyPublisher<Result<(PhotoModel, UIImage), Error>, Error> {
        return Future.init { [weak self] promise in
            guard let `self` = self else { return }
            switch result {
            case let .success((model, image)):
                guard let urlStr = model.urls.small else {
                    return
                }
                if image != nil {
                    promise(.success(.success((model, image!))))
                    return
                }
                self.photoService?
                    .download(urlStr: urlStr)
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { result in
                        switch result {
                        case .success(let image):
                            promise(.success(.success((model, image))))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    })
                    .store(in: &self.cancellables)
            case let .failure(error):
                promise(.failure(error))
            }
            
        }.eraseToAnyPublisher()
    }
    
    func cacheImage(_ result: Result<(PhotoModel, UIImage), Error>)
    -> AnyPublisher<Result<(PhotoModel, UIImage), Error>, Error> {
        return Future.init { [weak self] promise in
            guard let `self` = self else { return }
            switch result {
            case .failure(let error):
                promise(.failure(error))
            case let .success((model, image)):
                guard let urlStr = model.urls.small else {
                    return
                }
                self.imageCacheServie?
                    .cacheImage(urlStr: urlStr,
                                image: image)
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { result in
                        switch result {
                        case .success(let image):
                            promise(.success(.success((model, image))))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    })
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
}
