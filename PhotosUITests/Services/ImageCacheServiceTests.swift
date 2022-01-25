//
//  ImageCacheServiceTests.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import XCTest
import Combine
@testable import PhotosUI

class ImageCacheServiceTests: XCTestCase {
    
    var cancellables = [AnyCancellable]()
    
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
    
    func test_cache_failureImage() {
        // given
        let urlStr = "TestUrlStr"
        let image = UIImage()
        
        // when
        let expectation = expectation(description: "CacheError")
        service.cacheImage(urlStr: urlStr, image: image)
            .sink { completion in
                
                // then
                guard case .failure(let err) = completion else { return }
                XCTAssertEqual(err as? CacheError, CacheError.invalidImage)
                expectation.fulfill()
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetch_cachedImage() {
        let urlStr = "TestUrlStr"
        
        let expectation = expectation(description: "cachedImage")
        _ = service.fetchCachedImage(urlStr: urlStr)
            .sink { _ in
            } receiveValue: { result in
                guard case .success(let img) = result else { return }
                XCTAssertNotNil(img)
                expectation.fulfill()
            }
        
        let key = urlStr.removeSpecialCharsFromString()
        XCTAssertEqual(key, memoryCacheManager.key)
        wait(for: [expectation], timeout: 1)
    }
    
}
