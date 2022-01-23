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
    
    private var page: Int
    private var idx: Int
    private var keyword: String?
    
    // MARK: Inputs
    let fetchPhotos = PassthroughSubject<PhotoModel?, Never>()
    let loadImage = PassthroughSubject<PhotoModel, Never>()
    
    // MARK: Outputs
    @Published var photos = [PhotoModel]()
    @Published var photoImgMap = [PhotoModel: UIImage]()
    
    init(photos: [PhotoModel],
         photoImgMap: [PhotoModel: UIImage],
         page: Int,
         idx: Int,
         keyword: String?) {
        self.photos = photos
        self.photoImgMap = photoImgMap
        self.page = page
        self.idx = idx
        self.keyword = keyword
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
