//
//  KPPricing.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/28/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence
import Contentful

class KPPricing: Object, EntryPersistable {
    static var contentTypeId = "pricing"
    
    static func fieldMapping() -> [FieldName: String] {
        return [
            "pharmacy": "pharmacy",
            "drug": "drug",
            "coveredRange": "coveredRange",
            "notCoveredRange": "notCoveredRange"
        ]
    }
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var pharmacy: KPPharmacy?
    @objc dynamic var drug: KPDrug?
    @objc dynamic var coveredRange: String?
    @objc dynamic var notCoveredRange: String?
}
