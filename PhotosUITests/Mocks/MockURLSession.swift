//
//  MockURLSession.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/20.
//

import Foundation
@testable import PhotosUI

class MockURLSession: URLSessionProtocol {
    
    var request: URLRequest?
    var url: URL?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.request = request
        return URLSession(configuration: .default).dataTask(with: request)
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.url = url
        return URLSession(configuration: .default).dataTask(with: url)
    }
}

