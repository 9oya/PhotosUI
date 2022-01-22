//
//  PhotosView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI

struct PhotosView: View {
    
    @ObservedObject var viewModel: PhotosViewModel
    
    var body: some View {
        List(viewModel.photos) { model in
            Image(uiImage: self.viewModel.photoImgs[model] ?? UIImage())
                .listRowInsets(EdgeInsets())
                .onAppear {
                    self.viewModel.loadImage.send(model)
                }
        }
        .background(Color.black)
        .listStyle(.plain)
        .onAppear(perform: self.viewModel.fetchPhotos.send)
    }
}
