//
//  DetailViewModel.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/23.
//

import Foundation
import Combine
import SwiftUI

class DetailViewModel: ObservableObject {
    
    var provider: ServiceProviderProtocol?
    var cancellables: [AnyCancellable] = []

    var page: Int
    private var keyword: String?
    
    // MARK: Inputs
    let idxChanged = PassthroughSubject<Int, Never>()
    let loadImage = PassthroughSubject<PhotoModel, Never>()
    
    // MARK: Outputs
    @Published var photos = [PhotoModel]()
    @Published var photoImgMap = [PhotoModel: UIImage]()
    @Published var isLoading: Bool = false
    
    init(provider: ServiceProviderProtocol,
         photos: [PhotoModel],
         photoImgMap: [PhotoModel: UIImage],
         page: Int,
         keyword: String?) {
        self.page = page
        self.provider = provider
        self.photoImgMap = photoImgMap
        self.keyword = keyword
        self.photos = photos
        
        idxChanged
            .setFailureType(to: Error.self)
            .filter({ idx in
                return idx >= self.photos.count-2
            })
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .flatMap { [weak self] model -> AnyPublisher<[PhotoModel], Error> in
                guard let `self` = self,
                      let provider = self.provider,
                      let clinetId = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                if let keyword = self.keyword {
                    return provider
                        .photoService
                        .search(keyword: keyword,
                                page: self.page,
                                clientId: clinetId)
                }
                return provider
                    .photoService
                    .photos(page: self.page,
                            clientId: clinetId)
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { compl in
                guard case .failure(let error) = compl else { return }
                print(error.localizedDescription)
            }, receiveValue: { [weak self] photos in
                guard let `self` = self else { return }
                self.photos.append(contentsOf: photos)
                self.page += 1
                self.isLoading = false
            })
            .store(in: &self.cancellables)
            
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

extension DetailViewModel {
    
    func width() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        return screenWidth
    }
    
    func height(_ model: PhotoModel) -> CGFloat {
        let ratio = width() / CGFloat(model.width)
        let height = CGFloat(model.height) * ratio
        return height
    }
    
}
