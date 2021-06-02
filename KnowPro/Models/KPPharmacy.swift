//
//  KPPharmacy.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/28/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence
import Contentful

class KPPharmacy: Object, EntryPersistable {
    static var contentTypeId = "pharmacy"
    
    static func fieldMapping() -> [FieldName: String] {
        return [
            "name": "name",
            "logo": "logo",
            "address": "address",
            "phoneNumber": "phoneNumber",
            "website": "website"
        ]
    }
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var name: String?
    @objc dynamic var logo: KPAsset?
    @objc dynamic var address: String?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var website: String?
    
    func logoURL() -> URL? {
        if let logo = self.logo, let urlString = logo.urlString {
            return URL(string: urlString)
        }
        
        return nil
    }
    
    func contactInfo() -> String {
        var contactInfo = ""
        
        if let name = name {
            contactInfo.append(name)
        }
        
        if let address = address {
            if contactInfo.count > 0 {
                contactInfo.append("\n")
            }
            
            contactInfo.append(address)
        }
        
        if let phoneNumber = phoneNumber {
            if contactInfo.count > 0 {
                contactInfo.append("\n\n")
            }
            
            contactInfo.append("P: \t\(phoneNumber)")
        }
        
        if let website = website {
            if contactInfo.count > 0 {
                contactInfo.append("\n\n")
            }
            
            contactInfo.append(website)
        }
        
        return contactInfo
    }
}
