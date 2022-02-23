//
//  CachedImageDownloader.swift
//
//
//  Created by Gary Hanson on 6/12/21.
//


import SwiftUI



enum ImageLoader {

    static func downloadImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.invalidServerResponse
        }
        
        guard let uimage = UIImage(data: data) else {
            throw NetworkError.invalidImageData
        }
        
        return uimage
    }
}

/*
 
// if downloading a lot of large images. keep them small for caching.
extension UIImage {
    var thumbnail: UIImage? {
        get async {
            //TODO: these are specific for this app
            let size = CGSize(width: 100, height: 60)
            return await self.byPreparingThumbnail(ofSize: size)
        }
    }
}

actor CachedImageDownloader {
    // because this is static it should only be set once for the app.
    // if you want to have the option to have both just create a separate CachedImageDownloaderwithThumbnails.
    // this is used statically because there will be a lot of images downloaded for the news stories.
    // if only a relatively few images will be downloaded then no problem in making this not static and just
    //      instantiating a downloader whereever it is called.
    static var makeThumbnails = false
    
    private enum CacheEntry {
        case inProgress(Task<UIImage, Error>)
        case ready(Image)
    }
    
    static private var cache: [URL: CacheEntry] = [:]
    
    static func image(from url: URL) async throws -> Image? {
        if let cached = cache[url] {
            switch cached {
            case .ready(let image):
                return image
            case .inProgress(let handle):
                return try await Image(uiImage: handle.value)
            }
        }
        
        let handle = Task.init {
            try await ImageLoader.downloadImage(from: url)
        }
        
        cache[url] = .inProgress(handle)
        
        do {
            var image = try await handle.value
            if makeThumbnails {
                if let thumbnail = await image.thumbnail {
                    image = thumbnail
                } else {
                    throw NetworkError.invalidImageForThumbnail
                }
            }
            let finalImage = Image(uiImage: image).resizable()
            cache[url] = .ready(finalImage)
            
            return finalImage
        } catch {
            cache[url] = nil
            throw error
        }
    }
}

*/
