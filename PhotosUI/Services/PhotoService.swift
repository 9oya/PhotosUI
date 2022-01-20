//
//  PhotoService.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import Combine
import Foundation

protocol PhotoServiceProtocol {
    func photos(page: Int,
                clientId: String)
    -> AnyPublisher<[PhotoModel], Error>
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
        return Future<[PhotoModel], Error>.init { promise in
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
}
