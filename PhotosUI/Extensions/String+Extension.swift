//
//  String+Extension.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/22.
//

extension String {
    func removeSpecialCharsFromString() -> String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter { okayChars.contains($0) }
    }
}
