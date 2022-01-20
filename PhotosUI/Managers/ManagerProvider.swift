//
//  ManagerProvider.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import Foundation

protocol ManagerProviderProtocol {
    var networkManager: NetworkManagerProtocol { get }
}

struct ManagerProvider: ManagerProviderProtocol {
    var networkManager: NetworkManagerProtocol
}

extension ManagerProvider {
    static func resolve() -> ManagerProviderProtocol {
        
        let urlSession = URLSession(configuration: .default)
        
        return ManagerProvider(
            networkManager: NetworkManager(session: urlSession)
        )
    }
}
