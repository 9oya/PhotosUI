//
//  ImageCacheServiceTests.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import XCTest
@testable import PhotosUI

class ImageCacheServiceTests: XCTestCase {
    
    var provider: ManagerProviderProtocol!
    var memoryCacheManager: MockMemoryCacheManager!
    var diskCacheManager: MockDiskCacheManager!
    var service: ImageCacheServiceProtocol!

    override func setUpWithError() throws {
        provider = MockManagerProvider.stubs()
        memoryCacheManager = provider.memoryCacheManager as? MockMemoryCacheManager
        diskCacheManager = provider.diskCacheManager as? MockDiskCacheManager
        service = ImageCacheService(provider: provider)
    }

    override func tearDownWithError() throws {
        service = nil
        diskCacheManager = nil
        memoryCacheManager = nil
        provider = nil
    }

    func test_cacheImage() {
        let urlStr = "TestUrlStr"
        let image = UIImage(named: "defaultImg")!
        
        _ = service.cacheImage(urlStr: urlStr, image: image)
            .sink { _ in
            } receiveValue: { _ in
            }
        
        let key = urlStr.removeSpecialCharsFromString()
        guard let data = image.pngData() else {
            fatalError()
        }
        
        XCTAssertEqual(key, memoryCacheManager.key)
        XCTAssertEqual(image, memoryCacheManager.image)
        
        XCTAssertEqual(key, diskCacheManager.key)
        XCTAssertEqual(data, diskCacheManager.data)
    }
    
    func test_fetchCachedImage() {
        let urlStr = "TestUrlStr"
        let image = UIImage(named: "defaultImg")!
        
        _ = service.cacheImage(urlStr: urlStr, image: image)
            .sink { _ in
            } receiveValue: { _ in
            }
        
        let key = urlStr.removeSpecialCharsFromString()
        XCTAssertEqual(key, memoryCacheManager.key)
    }
}
