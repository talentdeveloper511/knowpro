//
//  KPAsset.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/21/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence

class KPAsset: Object, AssetPersistable {
    @objc dynamic var title: String?
    
    @objc dynamic var assetDescription: String?
    
    @objc dynamic var urlString: String?
    
    @objc dynamic var fileName: String?
    
    @objc dynamic var fileType: String?
    
    @objc dynamic var size: NSNumber? = 0
    
    @objc dynamic var width: NSNumber? = 0
    
    @objc dynamic var height: NSNumber? = 0
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
}
