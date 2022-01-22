//
//  MemoryCacheManagerTests.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import XCTest
@testable import PhotosUI

class MemoryCacheManagerTests: XCTestCase {
    
    var cache: MockNSChache!
    var manager: MemoryCacheManagerProtocol!

    override func setUpWithError() throws {
        cache = MockNSChache()
        manager = MemoryCacheManager(cacheManager: cache)
    }

    override func tearDownWithError() throws {
        manager = nil
        cache = nil
    }
    
    func testMemoryCache_store() {
        // given
        let key = "TestKey"
        let image = UIImage()
        
        // when
        manager.store(key: key, image: image)
        
        // then
        XCTAssertEqual(key as NSString, cache.key)
        XCTAssertEqual(image, cache.object(forKey: key as NSString)! as UIImage)
    }
    
    func testMemoryCache_fetch() {
        let key = "TestKey"
        
        _ = manager.fetch(key: key)
        
        XCTAssertEqual(key as NSString, cache.key)
    }
    
}
