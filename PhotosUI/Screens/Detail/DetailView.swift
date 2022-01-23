//
//  DetailView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI
import Combine

struct DetailView: View {
    
    @ObservedObject var viewModel: DetailViewModel
    
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
                        .onAppear(perform: {
                            self.viewModel.loadImage.send(model)
                        })
                        .background(Color.yellow)
                    Spacer()
                }
            }
        }.onReceive(Just(currIdx), perform: { value in
            if !self.viewModel.isLoading {
                self.viewModel.idxChanged.send(value)
            }
        })
    }
}
