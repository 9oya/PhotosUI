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
                    self.viewModel.fetchPhotos.send((keyword, nil))
                }
                .padding([.leading, .trailing], 8)
                .frame(height: 32)
                .background(Color.white.opacity(0.4))
                .cornerRadius(8)
                Button(LocalizedStringKey("Search")) {
                    self.viewModel.fetchPhotos.send((keyword, nil))
                }
            }
            .padding([.leading, .trailing], 16)
            List(viewModel.iterateRange, id: \.self) { i in
                HStack(spacing: 0) {
                    ForEach(0..<2, id: \.self) { j in
                        let model = viewModel.photos[(i*2)+j]
                        Image(uiImage: self.viewModel.photoImgMap[model] ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: self.viewModel.width(),
                                   height: self.viewModel.height())
                            .background(ListScrollingHelper(proxy: self.scrollingProxy))
                            .clipped()
                            .onAppear {
                                self.viewModel.loadImage.send(model)
                                self.viewModel.fetchPhotos.send((keyword, model))
                            }
                            .onTapGesture {
                                self.selectedItem = model
                            }
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width,
                       height: self.viewModel.height())
                .listRowInsets(EdgeInsets())
            }
            .background(Color.black)
            .listStyle(.plain)
            .onAppear {
            }
            .sheet(item: self.$selectedItem, content: { model in
                let vm = DetailViewModel(provider: self.viewModel.provider!,
                                         photos: self.viewModel.photos,
                                         photoImgMap: self.viewModel.photoImgMap,
                                         page: self.viewModel.page,
                                         keyword: keyword)
                DetailView(viewModel: vm,
                           currentIndex: self.viewModel.photos.firstIndex(where: { $0 == model }) ?? 0,
                           photoViewIdx: self.$detailIdx)
                    .onDisappear {
                        self.viewModel.page = vm.page
                        self.viewModel.photos = vm.photos
                        self.viewModel.iterateRange = 0..<self.viewModel.photos.count/2
                        self.viewModel.photoImgMap = vm.photoImgMap
                        self.viewModel.hasScrolled = false
                        print("DetailView onDisappear")
                    }
            })
            .onReceive(Just(detailIdx).receive(on: RunLoop.main)) { value in
                if detailIdx > 0 && !viewModel.hasScrolled {
                    print("Start scrolling!!")
                    self.scrollingProxy
                        .scrollTo(.point(point: self.viewModel.nextPoint(value),
                                         animated: false))
                    viewModel.hasScrolled = true
                }
            }
            .onReceive(Just(self.viewModel.scrollToTop)) { value in
                if value {
                    DispatchQueue.main.async {
                        self.scrollingProxy.scrollTo(.top(animated: false))
                    }
                    self.viewModel.scrollToTop = false
                }
            }
        }
    }
}
