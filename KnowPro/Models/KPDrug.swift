//
//  KPDrug.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/28/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence
import Contentful

class KPDrug: Object, EntryPersistable {
    static var contentTypeId = "drug"
    
    static func fieldMapping() -> [FieldName: String] {
        return [
            "name": "name",
            "info": "info",
            "producer": "producer",
            "copayCard": "copayCard",
            "requestSamplesLink": "requestSamplesLink",
            "contactPhoneNumber": "contactPhoneNumber",
            "requestMslLink": "requestMslLink",
            "requestLiteratureLink": "requestLiteratureLink",
            "requestMarketingMaterialsLink": "requestMarketingMaterialsLink",
            "generalContactLink": "generalContactLink",
            "articles": "articles",
            "indications": "indications",
            "precautions": "precautions",
            "contraindications": "contraindications",
            "dosageInformation": "dosageInformation",
            "moreInfo": "moreInfo",
            "preferredPharmacies": "preferredPharmacies",
            "primaryColor": "primaryColor",
            "secondaryColor": "secondaryColor",
            "smallLogo": "smallLogo",
            "largeLogo": "largeLogo",
            "galleryMedia": "galleryMedia",
            "copayCardLink": "copayCardLink"
        ]
    }
    
    // Disabling linter warning due to required protocol
    // swiftlint:disable:next identifier_name
    @objc dynamic var id: String = ""
    
    @objc dynamic var localeCode: String?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var name: String?
    @objc dynamic var info: String?
    @objc dynamic var producer: KPCompany?
    @objc dynamic var copayCard: KPAsset?
    @objc dynamic var copayCardLink: String?
    @objc dynamic var requestSamplesLink: String?
    @objc dynamic var contactPhoneNumber: String?
    @objc dynamic var requestMslLink: String?
    @objc dynamic var requestLiteratureLink: String?
    @objc dynamic var requestMarketingMaterialsLink: String?
    @objc dynamic var generalContactLink: String?
    @objc dynamic var primaryColor: String?
    @objc dynamic var secondaryColor: String?
    @objc dynamic var largeLogo: KPAsset?
    @objc dynamic var smallLogo: KPAsset?
    
    let articles = List<KPArticle>()
    let indications = List<KPIndication>()
    let precautions = List<KPPrecaution>()
    let contraindications = List<KPContraindication>()
    let dosageInformation = List<KPDosageInstruction>()
    let moreInfo = List<KPGeneralInformation>()
    let preferredPharmacies = List<KPPharmacy>()
    let galleryMedia = List<KPAsset>()
    
    func smallLogoURL() -> URL? {
        if let smallLogo = self.smallLogo, let urlString = smallLogo.urlString {
            return URL(string: urlString)
        }
        
        return nil
    }
    
    func copayCardURL() -> URL? {
        if let copayCard = self.copayCard, let urlString = copayCard.urlString {
            return URL(string: urlString)
        }
        
        return nil
    }
}
