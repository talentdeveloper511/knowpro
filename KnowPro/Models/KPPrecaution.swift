//
//  KPPrecaution.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/28/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence
import Contentful

class KPPrecaution: Object, EntryPersistable {
    static var contentTypeId = "precaution"
    
    static func fieldMapping() -> [FieldName: String] {
        return [
            "title": "title",
            "content": "content"
        ]
    }
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var title: String?
    @objc dynamic var content: String?
}
