//
//  MockManagerProvider.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/20.
//

import Foundation
@testable import PhotosUI

struct MockManagerProvider: ManagerProviderProtocol {
    var networkManager: NetworkManagerProtocol
    var memoryCacheManager: MemoryCacheManagerProtocol
    var diskCacheManager: DiskCacheManagerProtocol
}

extension MockManagerProvider {
    static func stubs() -> MockManagerProvider {
        return MockManagerProvider(
            networkManager: MockNetworkManager(),
            memoryCacheManager: MockMemoryCacheManager(),
            diskCacheManager: MockDiskCacheManager()
        )
    }
}
