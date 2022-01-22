//
//  DiskCacheManagerTests.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import XCTest
@testable import PhotosUI

class DiskCacheManagerTests: XCTestCase {

    var fileManager: MockFileManager!
    var manager: DiskCacheManagerProtocol!

    override func setUpWithError() throws {
        fileManager = MockFileManager()
        manager = DiskCacheManager(fileManager: fileManager)
    }

    override func tearDownWithError() throws {
        manager = nil
        fileManager = nil
    }

    func testDisckCacheManager_store() {
        // given
        let key = "TestKey"
        let data = Data(base64Encoded: "TestData")!
        
        // when
        _ = manager.store(key: key, data: data)
        
        // then
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError()
        }
        var filePath = URL(fileURLWithPath: path)
        filePath.appendPathComponent(key)
        XCTAssertEqual(filePath.path, fileManager.path)
    }

    func testDisckCacheManager_fetch() {
        // given
        let key = "TestKey"
        
        // when
        _ = manager.fetch(key: key)
        
        // then
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError()
        }
        var filePath = URL(fileURLWithPath: path)
        filePath.appendPathComponent(key)
        XCTAssertEqual(filePath.path, fileManager.path)
    }
}
