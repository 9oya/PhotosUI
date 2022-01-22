//
//  MockDiskCacheManager.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import Foundation
@testable import PhotosUI

class MockDiskCacheManager: DiskCacheManagerProtocol {
    
    var key: String?
    var data: Data?
    
    func fetch(key: String) -> Data? {
        self.key = key
        return Data()
    }
    
    func store(key: String, data: Data) -> Bool {
        self.key = key
        self.data = data
        return true
    }
}
