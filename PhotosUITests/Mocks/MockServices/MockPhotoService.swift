//
//  MockPhotoService.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import Foundation
import UIKit
import Combine
@testable import PhotosUI

class MockPhotoService: PhotoServiceProtocol {
    
    var page: Int?
    var clientId: String?
    var keyword: String?
    var urlStr: String?
    
    func photos(page: Int, clientId: String) -> AnyPublisher<[PhotoModel], Error> {
        self.page = page
        self.clientId = clientId
        return Future.init { promise in
            promise(.success([]))
        }.eraseToAnyPublisher()
    }
    
    func download(urlStr: String) -> AnyPublisher<Result<UIImage, Error>, Error> {
        self.urlStr = urlStr
        return Future.init { promise in
            promise(.success(.success(UIImage())))
        }.eraseToAnyPublisher()
    }
}
