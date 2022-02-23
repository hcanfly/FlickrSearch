//
//  Sections.swift
//  FlickrSearch
//
//  Created by Gary Hanson on 2/21/22.
//

import UIKit


class Section: Hashable {
    static var allSections: [Section] = []
    
    let id = UUID()
    let title: String
    let photos: [FlickrPhoto]
    
    init(title: String, photos: [FlickrPhoto]) {
        self.title = title
        self.photos = photos
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.id == rhs.id
    }
    
}

