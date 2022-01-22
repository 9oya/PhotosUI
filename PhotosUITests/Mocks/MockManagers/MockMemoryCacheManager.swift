//
//  MockMemoryCacheManager.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import Foundation
import UIKit
@testable import PhotosUI

class MockMemoryCacheManager: MemoryCacheManagerProtocol {
    
    var key: String?
    var image: UIImage?
    
    func fetch(key: String) -> UIImage? {
        self.key = key
        return UIImage()
    }
    
    func store(key: String, image: UIImage) {
        self.key = key
        self.image = image
    }
}
