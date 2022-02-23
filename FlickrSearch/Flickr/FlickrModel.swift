//
//  FlickrModel.swift
//  Flickr
//
//  Created by Gary Hanson on 9/11/21.
//

import UIKit


struct FlickrPhotoInfo: Codable {
    let id: String
    let farm: Int
    let server: String
    let secret: String
    let title: String
}

struct FlickrDownloadInfo: Codable {
    let photo: [FlickrPhotoInfo]
}

struct FlickrData: Codable {
    let photos: FlickrDownloadInfo
    let stat: String
}
