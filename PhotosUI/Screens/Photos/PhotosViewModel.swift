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
    private var page = 1
    
    // MARK: Inputs
    let fetchPhotos = PassthroughSubject<PhotoModel?, Never>()
    let loadImage = PassthroughSubject<PhotoModel, Never>()
    
    // MARK: Outputs
    @Published var photos = [PhotoModel]()
    @Published var photoImgs = [PhotoModel: UIImage]()
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
        
        fetchPhotos
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .flatMap { [weak self] model -> AnyPublisher<[PhotoModel], Error> in
                guard let `self` = self,
                      model == nil || model == self.photos[self.photos.count-2],
                      let provider = self.provider,
                      let clinetId = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return provider
                    .photoService
                    .photos(page: self.page,
                            clientId: clinetId)
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { photos in
                self.photos.append(contentsOf: photos)
                self.page += 1
            })
            .store(in: &self.cancellables)
        
        loadImage
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
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
            .receive(on: DispatchQueue.main)
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

extension PhotosViewModel {
    
    func width(_ model: PhotoModel) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        return screenWidth
    }
    
    func height(_ model: PhotoModel) -> CGFloat {
        let ratio = width(model) / CGFloat(model.width)
        let height = CGFloat(model.height) * ratio
        return height
    }
    
}
