//
//  FlickrSearch.swift
//  FlickrSearch
//
//  Created by Gary Hanson on 2/1/22.
//

import Foundation


let apiKey = "<Did you get an API key from Flickr?>"     // "<Did you get an API key from Flickr?>"

enum FlickrDownload {
    
    static func searchFlickr(for searchTerm: String) async throws -> [FlickrPhoto] {
        guard let searchURL = flickrSearchURLString(for: searchTerm) else {
            return []
        }
        
        return try await getFlickrPhotos(urlString: searchURL)
    }

    static func recentFlickr() async throws -> [FlickrPhoto] {
        let popularFlickrString = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(apiKey)&per_page=30&format=json&nojsoncallback=1"
        
        return try await getFlickrPhotos(urlString: popularFlickrString)
    }
    
    // called internally by search and recents, and by the Photo view which uses it to download single large image
    static func getPhotos(photoData: [FlickrPhotoInfo], getLargeImage: Bool) async throws -> [FlickrPhoto] {
        var photos: [FlickrPhoto] = []
        
        for photoObject in photoData {
            let flickrPhoto = FlickrPhoto(info: photoObject)
            
            guard let url = flickrPhoto.flickrImageURL(getLargeImage: getLargeImage) else { throw NetworkError.invalidURL }
            
            do {
                let image = try await ImageLoader.downloadImage(from: url)
                if getLargeImage {
                    flickrPhoto.largeImage = image
                } else {
                    flickrPhoto.thumbnail = image
                }
                
                photos.append(flickrPhoto)
            } catch {
                throw NetworkError.invalidImageData
            }
            
        }
        return photos
    }
    
    fileprivate static func getFlickrPhotos(urlString: String) async throws -> [FlickrPhoto] {
        var photos: [FlickrPhoto] = []
        do {
            let theData = try await NetworkService.fetch(urlString: urlString, myType: FlickrData.self)
            
            photos = try await getPhotos(photoData: theData.photos.photo, getLargeImage: false)
        } catch {
            throw NetworkError.invalidJSON
        }
        
        return photos
    }
    
    fileprivate static func flickrSearchURLString(for searchTerm: String) -> String? {
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=30&format=json&nojsoncallback=1"
        
        return URLString
    }
    
}
