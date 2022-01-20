//
//  PhotosView.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

import SwiftUI

struct PhotosView: View {
    
    @State var photos = ["1", "2", "3", "4"]
    
    var body: some View {
        List {
            ForEach(photos, id: \.self) { photo in
                Text(photo)
            }
        }
        .background(Color.black)
    }
}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView()
    }
}
