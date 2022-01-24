//
//  ContentView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI

struct ContentView: View {
    
    let provider: ServiceProviderProtocol
    
    var body: some View {
        TabView {
            PhotosView(viewModel: PhotosViewModel(provider: provider))
                .tabItem {
                    Image(
                        uiImage: UIImage(
                            systemName: "photo.fill.on.rectangle.fill",
                            withConfiguration: UIImage
                                .SymbolConfiguration(
                                    pointSize: 15.0,
                                    weight: .regular,
                                    scale: .large))!
                    )
                }
                .background(Color.black)
                .tag(0)
            SearchView(viewModel: SearchViewModel(provider: provider))
                .tabItem {
                    Image(
                        uiImage: UIImage(
                            systemName: "magnifyingglass",
                            withConfiguration: UIImage
                                .SymbolConfiguration(
                                    pointSize: 15.0,
                                    weight: .regular,
                                    scale: .large))!
                    )
                }
                .tag(1)
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
        
    }
}
