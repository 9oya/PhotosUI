//
//  ContentView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            PhotosView()
                .tabItem {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .resizable()
                }
                .tag(0)
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
