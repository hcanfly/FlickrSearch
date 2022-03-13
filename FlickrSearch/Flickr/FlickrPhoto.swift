//
//  FlickrPhoto.swift
//  FlickrPhoto
//
//  Created by Gary Hanson on 9/11/21.
//

import UIKit


final class FlickrPhoto: Equatable, Hashable {
    let title: String
    var thumbnail: UIImage?
    var largeImage: UIImage?
    let photoID: String
    let farm: Int
    let server: String
    let secret: String
    
    init (info: FlickrPhotoInfo) {
        self.photoID = info.id
        self.farm = info.farm
        self.server = info.server
        self.secret = info.secret
        self.title = info.title
    }
    
    func flickrImageURL(getLargeImage: Bool) -> URL? {
        let size = getLargeImage ? "b" : "m"
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(photoID)
    }
    static func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
        return lhs.photoID == rhs.photoID
    }
}
