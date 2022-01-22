//
//  PhotoService.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import Combine
import Foundation
import UIKit

enum DownloadImageError: Error, CustomStringConvertible {
    case invalidUrlStr
    case invalidData
    
    var description: String {
        switch self {
        case .invalidUrlStr:
            return "DownloadImageError: invalidUrlStr"
        case .invalidData:
            return "DownloadImageError: invalidData"
        }
    }
}

protocol PhotoServiceProtocol {
    
    func photos(page: Int,
                clientId: String)
    -> AnyPublisher<[PhotoModel], Error>
    
    func download(urlStr: String)
    -> AnyPublisher<Result<UIImage, Error>, Error>
    
}

class PhotoService: PhotoServiceProtocol {
    
    var provider: ManagerProviderProtocol
    var decoder: JSONDecoder
    
    init(provider: ManagerProviderProtocol,
         decoder: JSONDecoder) {
        self.provider = provider
        self.decoder = decoder
    }
    
    func photos(page: Int,
                clientId: String)
    -> AnyPublisher<[PhotoModel], Error> {
        let urlReq = APIRouter
            .getPhotos(clientId: clientId,
                       page: page)
            .asURLRequest()
        return Future<[PhotoModel], Error>.init { [weak self] promise in
            guard let `self` = self else { return }
            self.provider
                .networkManager
                .dataTask(request: urlReq) { result in
                    switch result {
                    case .success(let data):
                        do {
                            let model = try self.decoder
                                .decode([PhotoModel].self,
                                        from: data)
                            promise(.success(model))
                        } catch let error {
                            promise(.failure(error))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func download(urlStr: String)
    -> AnyPublisher<Result<UIImage, Error>, Error> {
        return Future.init { [weak self] promise in
            guard let `self` = self else { return }
            guard let url = URL(string: urlStr) else {
                promise(.failure(DownloadImageError.invalidUrlStr))
                return
            }
            self.provider
                .networkManager
                .dataTask(request: url) { result in
                    switch result {
                    case .failure(let error):
                        promise(.failure(error))
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            promise(.success(.success(image)))
                        } else {
                            promise(.failure(DownloadImageError.invalidData))
                        }
                    }
                }
        }.eraseToAnyPublisher()
    }
    
}
