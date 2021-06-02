//
//  KPArticle.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/28/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence
import Contentful
import SDWebImage

class KPArticle: Object, EntryPersistable {
    static var contentTypeId = "article"
    
    static func fieldMapping() -> [FieldName: String] {
        return [
            "title": "title",
            "author": "author",
            "link": "link",
            "description": "articleDescription",
            "source": "source",
            "sourceLogoUrl": "sourceLogoUrl",
            "sourceLogo": "sourceLogo",
            "image": "image",
            "imageUrl": "imageUrl",
            "mainFeed": "mainFeed",
            "promoted": "promoted",
            "drug": "drug"
        ]
    }
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var title: String?
    @objc dynamic var author: KPCompany?
    @objc dynamic var link: String?
    @objc dynamic var articleDescription: String?
    @objc dynamic var source: String?
    @objc dynamic var sourceLogoUrl: String?
    @objc dynamic var sourceLogo: KPAsset?
    @objc dynamic var image: KPAsset?
    @objc dynamic var imageUrl: String?
    @objc dynamic var drug: KPDrug?
    
    let mainFeed = RealmOptional<Bool>()
    let promoted = RealmOptional<Bool>()
    
    func imageURL() -> URL? {
        if let image = self.image, let urlString = image.urlString {
            return URL(string: urlString)
        }
        
        if let imageUrl = self.imageUrl {
            return URL(string: imageUrl)
        }
        
        return nil
    }
    
    func sourceLogoURL() -> URL? {
        if let sourceLogo = self.sourceLogo, let urlString = sourceLogo.urlString {
            return URL(string: urlString)
        }
        
        if let sourceLogoUrl = self.sourceLogoUrl {
            return URL(string: sourceLogoUrl)
        }
        
        return nil
    }
}
