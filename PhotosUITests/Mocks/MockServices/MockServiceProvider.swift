//
//  MockServiceProvider.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import Foundation
import UIKit
import Combine
@testable import PhotosUI

struct MockServiceProvider: ServiceProviderProtocol {
    var photoService: PhotoServiceProtocol
    var imageCacheServie: ImageCacheServiceProtocol
    var imageLoadService: ImageLoadServiceProtocol
}

extension MockServiceProvider {
    static func stubs() -> ServiceProviderProtocol {
        return MockServiceProvider(
            photoService: MockPhotoService(),
            imageCacheServie: MockImageCacheService(),
            imageLoadService: MockImageLoadService()
        )
    }
}
