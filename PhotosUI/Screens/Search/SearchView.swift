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
    @State var keyword: String = ""
    
    private let scrollingProxy = ListScrollingProxy()
    
    var body: some View {
        
        VStack {
            HStack {
                TextField("Search photos", text: $keyword) {
                    viewModel.searchPhotos.send((keyword, nil))
                }
                .padding([.leading, .trailing], 8)
                .frame(height: 32)
                .background(Color.white.opacity(0.4))
                .cornerRadius(8)
                Button(LocalizedStringKey("Search")) {
                    viewModel.searchPhotos.send((keyword, nil))
                }
            }
            .padding([.leading, .trailing], 16)
            List(viewModel.iterateRange, id: \.self) { i in
                HStack(spacing: 0) {
                    ForEach(0..<2, id: \.self) { j in
                        let model = viewModel.photos[(i*2)+j]
                        Image(uiImage: viewModel.photoImgMap[model] ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: viewModel.width(),
                                   height: viewModel.height())
                            .background(ListScrollingHelper(proxy: scrollingProxy))
                            .clipped()
                            .onAppear {
                                viewModel.loadImage.send(model)
                                viewModel.searchPhotos.send((keyword, model))
                            }
                            .onTapGesture {
                                selectedItem = model
                            }
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width,
                       height: viewModel.height())
                .listRowInsets(EdgeInsets())
            }
            .background(Color.black)
            .listStyle(.plain)
            .onAppear {
            }
            .sheet(item: $selectedItem, content: { model in
                let vm = DetailViewModel(provider: viewModel.provider!,
                                         photos: viewModel.photos,
                                         photoImgMap: viewModel.photoImgMap,
                                         page: viewModel.page,
                                         keyword: keyword)
                DetailView(viewModel: vm,
                           currentIndex: viewModel.photos.firstIndex(where: { $0 == model }) ?? 0,
                           photoViewIdx: $detailIdx)
                    .onDisappear {
                        viewModel.page = vm.page
                        viewModel.photos = vm.photos
                        viewModel.iterateRange = 0..<viewModel.photos.count/2
                        viewModel.photoImgMap = vm.photoImgMap
                        viewModel.hasScrolled = false
                        print("DetailView onDisappear")
                    }
            })
            .onReceive(Just(detailIdx)) { value in
                if detailIdx > 0 && !viewModel.hasScrolled {
                    print("Scroll to position!!")
                    scrollingProxy
                        .scrollTo(.point(point: viewModel.nextPoint(value),
                                         animated: false))
                    viewModel.hasScrolled = true
                }
            }
            .onReceive(Just(viewModel.scrollToTop)) { value in
                if value {
                    DispatchQueue.main.async {
                        scrollingProxy.scrollTo(.top(animated: false))
                    }
                    viewModel.scrollToTop = false
                }
            }
        }
    }
}
