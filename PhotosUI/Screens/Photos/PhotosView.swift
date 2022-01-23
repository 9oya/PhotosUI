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
        
        List(viewModel.photos, id: \.self) { model in
            Image(uiImage: self.viewModel.photoImgs[model] ?? UIImage())
                .listRowInsets(EdgeInsets())
                .frame(width: self.viewModel.width(model),
                       height: self.viewModel.height(model),
                       alignment: .center)
                .onAppear {
                    self.viewModel.loadImage.send(model)
                    self.viewModel.fetchPhotos.send(model)
                }
        }
        .background(Color.black)
        .listStyle(.plain)
        .onAppear {
            self.viewModel.fetchPhotos.send(nil)
        }
    }
}
