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
    
    @State var selectedItem: PhotoModel?
    @State var detailIdx: Int = -1
    
    private let scrollingProxy = ListScrollingProxy()
    
    var body: some View {
        
        List(viewModel.photos, id: \.self) { model in
            Image(uiImage: viewModel.photoImgMap[model] ?? UIImage())
                .listRowInsets(EdgeInsets())
                .frame(width: viewModel.width(model),
                       height: viewModel.height(model),
                       alignment: .center)
                .background(ListScrollingHelper(proxy: scrollingProxy))
                .onAppear {
                    viewModel.loadImage.send(model)
                    viewModel.fetchPhotos.send(model)
                }
                .onTapGesture {
                    selectedItem = model
                }
        }
        .background(Color.black)
        .listStyle(.plain)
        .onAppear {
            viewModel.fetchPhotos.send(nil)
        }
        .sheet(item: $selectedItem, content: { model in
            let vm = DetailViewModel(provider: viewModel.provider!,
                                     photos: viewModel.photos,
                                     photoImgMap: viewModel.photoImgMap,
                                     page: viewModel.page,
                                     keyword: nil)
            DetailView(viewModel: vm,
                       currentIndex: viewModel.photos.firstIndex(where: { $0 == model }) ?? 0,
                       photoViewIdx: $detailIdx)
                .onDisappear {
                    viewModel.page = vm.page
                    viewModel.photos = vm.photos
                    viewModel.photoImgMap = vm.photoImgMap
                    viewModel.hasScrolled = false
                    print("DetailView onDisappear")
                }
        })
        .onReceive(Just(detailIdx)) { value in
            if detailIdx > 0 && !viewModel.hasScrolled {
                print("Scroll to position!!")
                DispatchQueue.main.async {
                    scrollingProxy
                        .scrollTo(.point(point: viewModel.nextPoint(value),
                                         animated: false))
                }
                viewModel.hasScrolled = true
            }
        }
    }
    
}
