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
    let searchPhotos = PassthroughSubject<(String, PhotoModel?), Never>()
    let loadImage = PassthroughSubject<PhotoModel, Never>()
    
    // MARK: Outputs
    @Published var photos = [PhotoModel]()
    @Published var photoImgMap = [PhotoModel: UIImage]()
    @Published var iterateRange: Range<Int> = 0..<0
    @Published var scrollToTop: Bool = false
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
        
        searchPhotos
            .setFailureType(to: Error.self)
            .filter { [weak self] (keyword, model) in
                guard let `self` = self,
                      model == nil || model == self.photos[self.photos.count-1] else {
                          return false
                      }
                return true
            }
            .handleEvents(receiveOutput: { [weak self] (keyword, model) in
                guard let `self` = self else { return }
                if model == nil {
                    self.isNewKeyword = true
                    self.page = 1
                } else {
                    self.isNewKeyword = false
                }
            })
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .flatMap { [weak self] (keyword, model) -> AnyPublisher<[PhotoModel], Error> in
                guard let `self` = self,
                      let provider = self.provider,
                      let clinetId = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return provider
                    .photoService
                    .search(keyword: keyword,
                            page: self.page,
                            clientId: clinetId)
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { compl in
                guard case .failure(let error) = compl else { return }
                print(error.localizedDescription)
            }, receiveValue: { photos in
                if !self.isNewKeyword {
                    self.photos.append(contentsOf: photos)
                } else {
                    self.photos = photos
                    self.scrollToTop = true
                }
                self.page += 1
                self.iterateRange = 0..<self.photos.count/2
            })
            .store(in: &cancellables)
        
        loadImage
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .flatMap(provider.imageLoadService.fetchCachedImage)
            .flatMap(provider.imageLoadService.downloadImage)
            .flatMap(provider.imageLoadService.cacheImage)
            .receive(on: DispatchQueue.main)
            .sink { compl in
                guard case .failure(let error) = compl else { return }
                print(error.localizedDescription)
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
        let height: CGFloat = (self.height()*CGFloat(idx+1))/2
        return CGPoint(x: 0,
                       y: height)
    }
}
