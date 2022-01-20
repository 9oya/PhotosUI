//
//  PhotoModel.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/20.
//

struct PhotoModel: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String?
    let width: Int
    let height: Int
    let color: String?
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: Urls
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width, height, color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description, urls, links
    }
    
    struct Urls: Codable {
        let raw: String?
        let full: String?
        let regular: String?
        let small: String?
        let thumb: String?
    }
    
    struct Links: Codable {
        let its: String?
        let html: String?
        let download: String?
        let downloadLocation: String?
        
        enum CodingKeys: String, CodingKey {
            case its = "self"
            case html
            case download
            case downloadLocation = "download_location"
        }
    }
}

struct SearchPhotoModel: Codable {
    let total: Int
    let totalPages: Int
    let results: [PhotoModel]?
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}
