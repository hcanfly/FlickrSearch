//
//  NetworkService.swift
//  Dogs
//
//  Created by Gary Hanson on 1/30/22.
//

import SwiftUI

enum NetworkError: Error {
    case invalidURL
    case invalidServerResponse
    case invalidJSON
    case invalidImageData
    case invalidImageForThumbnail
}

enum NetworkService {
    
    static func fetch<T: Decodable>(urlString: String, myType: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
                
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.invalidServerResponse
        }
        
        //print(String(bytes: data, encoding: String.Encoding.utf8))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase     // e.g. converts first_name to firstName
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.invalidJSON
        }
    }

}
