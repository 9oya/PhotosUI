//
//  PhotosViewModel.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/21.
//

import UIKit
import Combine
import SwiftUI

class PhotosViewModel: ObservableObject {
    
    var provider: ServiceProviderProtocol?
    var cancellables: [AnyCancellable] = []
    
    let fetchPhotos = PassthroughSubject<Void, Never>()
    let loadImage = PassthroughSubject<PhotoModel, Never>()
    
    @Published var photos = [PhotoModel]()
    @Published var photoImgs = [PhotoModel: UIImage]()
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
        
        fetchPhotos
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.provider?
                    .photoService
                    .photos(page: 1, clientId: "CKofQaRSPXUTet3jmUM4WAswOpQMbEfCjSt2h0zOCKE")
                    .replaceError(with: [])
                    .receive(on: RunLoop.main, options: .none)
                    .assign(to: \.photos, on: self)
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
        
        loadImage
            .sink { [weak self] model in
                guard let `self` = self,
                      case .none = self.photoImgs[model],
                      let urlStr = model.urls.small else {
                          return
                      }
                self.provider?
                    .photoService
                    .download(urlStr: urlStr)
                    .replaceError(with: UIImage())
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { result in
                        self.photoImgs[model] = result
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
    
}
