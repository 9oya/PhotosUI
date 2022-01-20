//
//  MockNetworkManager.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/20.
//

import Foundation
@testable import PhotosUI

class MockNetworkManager: NetworkManagerProtocol {
    
    var url: URL?
    var urlRequest: URLRequest?
    
    func dataTask(request: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        self.url = request
        completion(.success(Data()))
    }
    
    func dataTask(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        self.urlRequest = request
        completion(.success(Data()))
    }
    
}
