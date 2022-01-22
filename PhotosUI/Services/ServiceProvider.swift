//
//  ServiceProvider.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/21.
//

import Foundation

protocol ServiceProviderProtocol {
    var photoService: PhotoServiceProtocol { get }
    var imageCacheServie: ImageCacheServiceProtocol { get }
    var imageLoadService: ImageLoadServiceProtocol { get }
}

struct ServiceProvider: ServiceProviderProtocol {
    var photoService: PhotoServiceProtocol
    var imageCacheServie: ImageCacheServiceProtocol
    var imageLoadService: ImageLoadServiceProtocol
}

extension ServiceProvider {
    static func resolve() -> ServiceProviderProtocol {
        
        let manager = ManagerProvider.resolve()
        
        let photoService = PhotoService(provider: manager,
                                        decoder: JSONDecoder())
        let imageCacheServie = ImageCacheService(provider: manager)
        
        return ServiceProvider(
            photoService: photoService,
            imageCacheServie: imageCacheServie,
            imageLoadService: ImageLoadService(photoService: photoService,
                                               imageCacheServie: imageCacheServie)
        )
    }
}
