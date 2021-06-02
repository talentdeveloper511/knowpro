//
//  KPAdvertisement.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/28/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence
import Contentful

enum KPAdvertisementType: String {
    case banner = "Banner"
    case bottom = "Bottom"
    case top = "Top"
    case full = "Full Screen"
}

class KPAdvertisement: Object, EntryPersistable {
    static var contentTypeId = "advertisement"
    
    static func fieldMapping() -> [FieldName: String] {
        return [
            "advertisementId": "advertisementId",
            "adType": "adType",
            "content": "content",
            "link": "link"
        ]
    }
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var adType: String?
    @objc dynamic var content: KPAsset?
    @objc dynamic var link: String?
    @objc dynamic var advertisementId: String?
    
    func imageURL() -> URL? {
        if let image = self.content, let urlString = image.urlString {
            return URL(string: urlString)
        }
        
        return nil
    }
}
