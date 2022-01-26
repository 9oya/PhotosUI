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
    var page = 1
    var hasScrolled: Bool = false
    
    // MARK: Inputs
    let fetchPhotos = PassthroughSubject<PhotoModel?, Never>()
    let loadImage = PassthroughSubject<PhotoModel, Never>()
    
    // MARK: Outputs
    @Published var photos = [PhotoModel]()
    @Published var photoImgMap = [PhotoModel: UIImage]()
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
        
        fetchPhotos
            .setFailureType(to: Error.self)
            .filter { [weak self] model in
                guard let `self` = self,
                      model == nil || model == self.photos[self.photos.count-2] else {
                          return false
                      }
                return true
            }
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .flatMap { [weak self] model -> AnyPublisher<[PhotoModel], Error> in
                guard let `self` = self,
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
            .sink(receiveCompletion: { compl in
                guard case .failure(let error) = compl else { return }
                print(error.localizedDescription)
            }, receiveValue: { photos in
                self.photos.append(contentsOf: photos)
                self.page += 1
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
    
    func nextPoint(_ idx: Int) -> CGPoint {
        var height: CGFloat = 0
        height = (0...idx).reduce(0) {
            $0 + CGFloat(self.height(self.photos[$1]))
        }
        return CGPoint(x: 0,
                       y: height)
    }
}
