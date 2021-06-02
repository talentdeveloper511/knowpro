//
//  KPCompany.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/28/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence
import Contentful

class KPCompany: Object, EntryPersistable {
    static var contentTypeId = "company"
    
    static func fieldMapping() -> [FieldName: String] {
        return [
            "name": "name",
            "largeLogo": "largeLogo",
            "smallLogo": "smallLogo",
            "info": "info",
            "website": "website",
            "contactLink": "contactLink",
            "contactPhoneNumber": "contactPhoneNumber",
            "drugs": "drugs",
            "articles": "articles",
            "primaryColor": "primaryColor",
            "secondaryColor": "secondaryColor",
            "premium": "premium",
            "galleryMedia": "galleryMedia",
            "requestSamplesLink": "requestSamplesLink",
            "requestMslLink": "requestMslLink",
            "requestLiteratureLink": "requestLiteratureLink",
            "requestMarketingMaterialsLink": "requestMarketingMaterialsLink"
        ]
    }
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var name: String?
    @objc dynamic var largeLogo: KPAsset?
    @objc dynamic var smallLogo: KPAsset?
    @objc dynamic var info: String?
    @objc dynamic var website: String?
    @objc dynamic var contactLink: String?
    @objc dynamic var contactPhoneNumber: String?
    @objc dynamic var primaryColor: String?
    @objc dynamic var secondaryColor: String?
    @objc dynamic var requestSamplesLink: String?
    @objc dynamic var requestMslLink: String?
    @objc dynamic var requestLiteratureLink: String?
    @objc dynamic var requestMarketingMaterialsLink: String?
    
    let drugs = List<KPDrug>()
    let articles = List<KPArticle>()
    let premium = RealmOptional<Bool>()
    let galleryMedia = List<KPAsset>()

    func smallLogoURL() -> URL? {
        if let smallLogo = self.smallLogo, let urlString = smallLogo.urlString {
            return URL(string: urlString)
        }
        
        return nil
    }
    
    func largeLogoURL() -> URL? {
        if let largeLogo = self.largeLogo, let urlString = largeLogo.urlString {
            return URL(string: urlString)
        }
        
        return nil
    }
}
