//
//  ServiceProvider.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/21.
//

import Foundation

protocol ServiceProviderProtocol {
    var photoService: PhotoServiceProtocol { get }
}

struct ServiceProvider: ServiceProviderProtocol {
    var photoService: PhotoServiceProtocol
}

extension ServiceProvider {
    static func resolve() -> ServiceProviderProtocol {
        
        let manager = ManagerProvider.resolve()
        
        return ServiceProvider(
            photoService: PhotoService(provider: manager,
                                       decoder: JSONDecoder())
        )
    }
}
