//
//  KPReferences.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/9/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence
import Contentful

class KPReferences: Object, EntryPersistable {

    static var contentTypeId = "references"
    
    static func fieldMapping() -> [FieldName: String] {
        return [
            "pdf": "pdf"
        ]
    }
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var pdf: KPAsset?
    
    func pdfURL() -> URL? {
        if let pdf = self.pdf, let urlString = pdf.urlString {
            return URL(string: urlString)
        }
        
        return nil
    }
}
