//
//  ImageLoadServiceTests.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import XCTest
@testable import PhotosUI

class ImageLoadServiceTests: XCTestCase {
    
    var provider: ServiceProviderProtocol!
    var photoService: MockPhotoService!
    var imageCachService: MockImageCacheService!
    var service: ImageLoadServiceProtocol!
    
    override func setUpWithError() throws {
        provider = MockServiceProvider.stubs()
        photoService = provider.photoService as? MockPhotoService
        imageCachService = provider.imageCacheServie as? MockImageCacheService
        service = ImageLoadService(photoService: provider.photoService,
                                   imageCacheServie: provider.imageCacheServie)
    }

    override func tearDownWithError() throws {
        service = nil
        imageCachService = nil
        photoService = nil
        provider = nil
    }

    func testFetchCachedImage() {
        // given
        let model = PhotoModel(id: "", createdAt: "", updatedAt: "", width: 0, height: 0, color: "", blurHash: "", likes: 0, likedByUser: false, description: "", urls: PhotoModel.Urls(raw: "", full: "", regular: "", small: "asdfasdfasd", thumb: ""), links: PhotoModel.Links(its: "", html: "", download: "", downloadLocation: ""))
        
        // when
        _ = service.fetchCachedImage(model)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
            })
        
        // then
        XCTAssertEqual(model.urls.small, imageCachService.urlStr)
    }
    
    func testDownloadImage_imageIsNil() {
        // given
        let model = PhotoModel(id: "", createdAt: "", updatedAt: "", width: 0, height: 0, color: "", blurHash: "", likes: 0, likedByUser: false, description: "", urls: PhotoModel.Urls(raw: "", full: "", regular: "", small: "asdfasdfasd", thumb: ""), links: PhotoModel.Links(its: "", html: "", download: "", downloadLocation: ""))
        let result: Result<(PhotoModel, UIImage?), Error> = .success((model, nil))
        
        // when
        _ = service.downloadImage(result)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
            })
        
        // then
        XCTAssertEqual(model.urls.small, photoService.urlStr)
    }
    
    func testDownloadImage_imageIsNotNil() {
        // given
        let model = PhotoModel(id: "", createdAt: "", updatedAt: "", width: 0, height: 0, color: "", blurHash: "", likes: 0, likedByUser: false, description: "", urls: PhotoModel.Urls(raw: "", full: "", regular: "", small: "asdfasdfasd", thumb: ""), links: PhotoModel.Links(its: "", html: "", download: "", downloadLocation: ""))
        let result: Result<(PhotoModel, UIImage?), Error> = .success((model, UIImage()))
        
        // when
        _ = service.downloadImage(result)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
            })
        
        // then
        XCTAssertEqual(nil, photoService.urlStr)
    }
}
