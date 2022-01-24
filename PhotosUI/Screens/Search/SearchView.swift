//
//  SearchView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI
import Combine

struct SearchView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    @State var selectedItem: PhotoModel?
    @State var detailIdx: Int = -1
    
    @State var offetY: CGFloat = 0.0
    
    private let scrollingProxy = ListScrollingProxy()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.iterateRange, id: \.self) { i in
                    HStack(spacing: 0) {
                        ForEach(0..<2, id: \.self) { j in
                            let model = viewModel.photos[(i*2)+j]
                            Image(uiImage: self.viewModel.photoImgMap[model] ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fill)
                                .listRowInsets(EdgeInsets())
                                .frame(width: self.viewModel.width(model),
                                       height: self.viewModel.height(model))
                                .background(ListScrollingHelper(proxy: self.scrollingProxy))
                                .onAppear {
                                    self.viewModel.loadImage.send(model)
                                    if !self.viewModel.isLoading {
                                        // self.viewModel.fetchPhotos.send(model)
                                    }
                                }
                                .onTapGesture {
                                    self.selectedItem = model
                                }
                        }
                    }
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
                        self.viewModel.hasScrolled = false
                        print("DetailView onDisappear")
                    }
            })
            .onReceive(Just(detailIdx)) { value in
                if detailIdx > 0 && !viewModel.hasScrolled {
                    print("Start scrolling!!")
                    self.scrollingProxy
                        .scrollTo(.point(point: self.viewModel.nextPoint(value),
                                         animated: false))
                    viewModel.hasScrolled = true
                }
            }
        }
    }
}
