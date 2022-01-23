//
//  DetailView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI

struct DetailView: View {
    
    @ObservedObject var viewModel: DetailViewModel
    
//    @State var currentPage: Int = 0
    @State var currIdx: Int
    
    var body: some View {
        PagerView(pageCount: viewModel.photos.count,
                  currentIndex: $currIdx) {
            ForEach(viewModel.photos) { model in
                VStack {
                    Spacer()
                    Image(uiImage: self.viewModel.photoImgMap[model] ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onAppear {
                            self.viewModel.loadImage.send(model)
                            self.viewModel.fetchPhotos.send(model)
                        }
                        .background(Color.yellow)
                    Spacer()
                }
            }
        }
    }
}
