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
    private var isNewKeyword: Bool = false
    
    // MARK: Inputs
    let fetchPhotos = PassthroughSubject<(String, PhotoModel?), Never>()
    let loadImage = PassthroughSubject<PhotoModel, Never>()
    
    // MARK: Outputs
    @Published var photos = [PhotoModel]()
    @Published var photoImgMap = [PhotoModel: UIImage]()
    @Published var iterateRange: Range<Int> = 0..<0
    @Published var scrollToTop: Bool = false
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
        
        fetchPhotos
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .flatMap { [weak self] (keyword, model) -> AnyPublisher<[PhotoModel], Error> in
                guard let `self` = self,
                      model == nil || model == self.photos[self.photos.count-1],
                      let provider = self.provider,
                      let clinetId = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                if model == nil {
                    self.isNewKeyword = true
                    self.page = 1
                } else {
                    self.isNewKeyword = false
                }
                return provider
                    .photoService
                    .search(keyword: keyword,
                            page: self.page,
                            clientId: clinetId)
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { photos in
                if !self.isNewKeyword {
                    self.photos.append(contentsOf: photos)
                    self.page += 1
                } else {
                    self.photos = photos
                    self.page = 1
                    self.scrollToTop = true
                }
                self.iterateRange = 0..<self.photos.count/2
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
    
    func width() -> CGFloat {
        let width = UIScreen.main.bounds.size.width / 2
        return width
    }
    
    func height() -> CGFloat {
        return width()*1.5
    }
    
    func nextPoint(_ idx: Int) -> CGPoint {
        let height: CGFloat = (self.height()*CGFloat(idx))/2
        return CGPoint(x: 0,
                       y: height)
    }
}
