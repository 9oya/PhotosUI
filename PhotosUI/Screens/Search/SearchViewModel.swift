//
//  SearchViewModel.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/24.
//

import UIKit
import Combine
import SwiftUI

class SearchViewModel: ObservableObject {
    
    var provider: ServiceProviderProtocol?
    var cancellables: [AnyCancellable] = []
    var page = 1
    var hasScrolled: Bool = false
    
    // MARK: Inputs
    let fetchPhotos = PassthroughSubject<PhotoModel?, Never>()
    let loadImage = PassthroughSubject<PhotoModel, Never>()
    
    // MARK: Outputs
    @Published var photos = [PhotoModel]()
    @Published var photoImgMap = [PhotoModel: UIImage]()
    @Published var iterateRange: Range<Int> = 0..<0
    @Published var isLoading: Bool = false
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
        
        fetchPhotos
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .flatMap { [weak self] model -> AnyPublisher<[PhotoModel], Error> in
                guard let `self` = self,
                      model == nil || model == self.photos[self.photos.count-1],
                      let provider = self.provider,
                      let clinetId = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                DispatchQueue.main.async {
                    self.isLoading = true
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
                self.iterateRange = 0..<self.photos.count/2
                self.isLoading = false
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
                    self.photoImgMap[model] = image
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
}

extension SearchViewModel {
    
    func width(_ model: PhotoModel) -> CGFloat {
        let width = UIScreen.main.bounds.size.width / 2
        return width
    }
    
    func height(_ model: PhotoModel) -> CGFloat {
        return width(model)*1.5
    }
    
    func nextPoint(_ idx: Int) -> CGPoint {
        var height: CGFloat = 0
        for i in 0...idx {
            height += CGFloat(self.height(self.photos[i]))
        }
        return CGPoint(x: 0,
                       y: height)
    }
}
