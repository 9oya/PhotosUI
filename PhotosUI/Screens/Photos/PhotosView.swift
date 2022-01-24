//
//  PhotosView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI
import Combine

struct PhotosView: View {
    
    @ObservedObject var viewModel: PhotosViewModel
    
    @State var showModal = false
    @State var selectedItem: PhotoModel?
    
    @State var detailIdx: Int = -1
    
    private let scrollingProxy = ListScrollingProxy()
    
    var body: some View {
        
        List(viewModel.photos, id: \.self) { model in
            Image(uiImage: self.viewModel.photoImgMap[model] ?? UIImage())
                .listRowInsets(EdgeInsets())
                .frame(width: self.viewModel.width(model),
                       height: self.viewModel.height(model),
                       alignment: .center)
                .background(ListScrollingHelper(proxy: self.scrollingProxy))
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
            let vm = DetailViewModel(provider: self.viewModel.provider!,
                                     photos: self.viewModel.photos,
                                     photoImgMap: self.viewModel.photoImgMap,
                                     page: self.viewModel.page,
                                     keyword: nil)
            DetailView(viewModel: vm,
                       currentIndex: self.viewModel.photos.firstIndex(where: { $0 == model }) ?? 0,
                       photoViewIdx: self.$detailIdx)
                .onDisappear {
                    self.viewModel.photos = vm.photos
                    self.viewModel.photoImgMap = vm.photoImgMap
                    print("DetailView onDisappear")
                }
        })
        .onReceive(Just(detailIdx)) { value in
            if detailIdx > 0 {
                print("String scrolling!!")
                self.scrollingProxy
                    .scrollTo(.point(point: self.viewModel.nextPoint(value),
                                     animated: false))
            }
        }
    }
    
}
