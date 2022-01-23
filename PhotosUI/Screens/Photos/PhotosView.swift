//
//  PhotosView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI
import AVFAudio

struct PhotosView: View {
    
    @ObservedObject var viewModel: PhotosViewModel
    
    @State var showModal = false
    @State var selectedItem: PhotoModel?
    
    var body: some View {
        
        List(viewModel.photos, id: \.self) { model in
            Image(uiImage: self.viewModel.photoImgMap[model] ?? UIImage())
                .listRowInsets(EdgeInsets())
                .frame(width: self.viewModel.width(model),
                       height: self.viewModel.height(model),
                       alignment: .center)
                .onAppear {
                    self.viewModel.loadImage.send(model)
                    self.viewModel.fetchPhotos.send(model)
                }
                .onTapGesture {
                    self.selectedItem = model
                }
        }
        .background(Color.black)
        .listStyle(.plain)
        .onAppear {
            self.viewModel.fetchPhotos.send(nil)
        }
        .sheet(item: self.$selectedItem, content: { model in
            let vm = DetailViewModel(photos: self.viewModel.photos,
                                     photoImgMap: self.viewModel.photoImgMap,
                                     page: self.viewModel.page,
                                     idx: self.viewModel.photos.firstIndex(where: { $0 == model }) ?? 0,
                                     keyword: nil)
            DetailView(viewModel: vm)
        })
    }
    
}
