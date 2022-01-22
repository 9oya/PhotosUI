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
            .setFailureType(to: Error.self)
            .flatMap { [weak self] model -> AnyPublisher<Result<(PhotoModel, UIImage?), Error>, Error> in
                guard let `self` = self,
                      let provider = self.provider else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return provider.imageLoadService.fetchCachedImage(model)
            }
            .flatMap { [weak self] result -> AnyPublisher<Result<(PhotoModel, UIImage), Error>, Error> in
                guard let `self` = self,
                      let provider = self.provider else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return provider.imageLoadService.downloadImage(result)
            }
            .flatMap { [weak self] result -> AnyPublisher<Result<(PhotoModel, UIImage), Error>, Error> in
                guard let `self` = self,
                      let provider = self.provider else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return provider.imageLoadService.cacheImage(result)
            }
            .receive(on: RunLoop.main, options: nil)
            .sink { _ in
            } receiveValue: { result in
                switch result {
                case .success(let (model, image)):
                    self.photoImgs[model] = image
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
}
