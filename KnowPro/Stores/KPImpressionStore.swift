//
//  KPImpressionStore.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/16/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import Flurry_iOS_SDK

class KPImpressionStore: NSObject {
    
    static let sharedStore = KPImpressionStore()
    
    private var realmQueue: DispatchQueue!
    
    override init() {
        super.init()
        
        realmQueue = DispatchQueue(label: "com.camber.KnowPro.impressionQueue")
    }

    func recordImpression(_ contentId: String, _ contentName: String, _ contentType: KPContentType) {
        self.realmQueue.async {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            do {
                let realm = try Realm()
                if realm.objects(KPImpression.self)
                    .filter(NSPredicate(format: "userId == %@ AND contentId == %@", uid, contentId))
                    .first != nil {
                    
                    Analytics.logEvent(KPConstants.Analytics.ItemImpression, parameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue])
                    Flurry.logEvent(KPConstants.Analytics.ItemImpression, withParameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue])
                    return
                }
                
                try realm.write {
                    let impression = realm.create(KPImpression.self)
                    impression.contentId = contentId
                    impression.userId = uid
                }
                
                Analytics.logEvent(KPConstants.Analytics.ItemImpression, parameters: [
                    AnalyticsParameterItemID: contentId,
                    AnalyticsParameterItemName: contentName,
                    AnalyticsParameterContentType: contentType.rawValue])
                Analytics.logEvent(KPConstants.Analytics.ItemImpressionUnique, parameters: [
                    AnalyticsParameterItemID: contentId,
                    AnalyticsParameterItemName: contentName,
                    AnalyticsParameterContentType: contentType.rawValue])
                Flurry.logEvent(KPConstants.Analytics.ItemImpression, withParameters: [
                    AnalyticsParameterItemID: contentId,
                    AnalyticsParameterItemName: contentName,
                    AnalyticsParameterContentType: contentType.rawValue])
                Flurry.logEvent(KPConstants.Analytics.ItemImpressionUnique, withParameters: [
                    AnalyticsParameterItemID: contentId,
                    AnalyticsParameterItemName: contentName,
                    AnalyticsParameterContentType: contentType.rawValue])
                
            } catch {
                
            }
        }
    }
    
    func recordView(_ contentId: String, _ contentName: String, _ contentType: KPContentType, _ duration: Double) {
        
        self.realmQueue.async {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            do {
                let realm = try Realm()
                
                var impression = realm.objects(KPImpression.self)
                    .filter(NSPredicate(format: "userId == %@ AND contentId == %@", uid, contentId))
                    .first
                if impression == nil {
                    try realm.write {
                        impression = realm.create(KPImpression.self)
                        impression?.contentId = contentId
                        impression?.userId = uid
                        impression?.convertedView.value = true
                    }
                    
                    Analytics.logEvent(KPConstants.Analytics.ItemImpression, parameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue])
                    Analytics.logEvent(KPConstants.Analytics.ItemImpressionUnique, parameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue])
                    Analytics.logEvent(KPConstants.Analytics.ViewItemUnique, parameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue,
                        KPConstants.Analytics.ParameterDuration: duration])
                    Flurry.logEvent(KPConstants.Analytics.ItemImpression, withParameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue])
                    Flurry.logEvent(KPConstants.Analytics.ItemImpressionUnique, withParameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue])
                    Flurry.logEvent(KPConstants.Analytics.ViewItemUnique, withParameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue,
                        KPConstants.Analytics.ParameterDuration: duration])

                } else if impression?.convertedView.value != true {
                    try realm.write {
                        impression?.convertedView.value = true
                    }
                    
                    Analytics.logEvent(KPConstants.Analytics.ViewItemUnique, parameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue,
                        KPConstants.Analytics.ParameterDuration: duration])
                    Flurry.logEvent(KPConstants.Analytics.ViewItemUnique, withParameters: [
                        AnalyticsParameterItemID: contentId,
                        AnalyticsParameterItemName: contentName,
                        AnalyticsParameterContentType: contentType.rawValue,
                        KPConstants.Analytics.ParameterDuration: duration])
                }
                
                Analytics.logEvent(AnalyticsEventViewItem, parameters: [
                    AnalyticsParameterItemID: contentId,
                    AnalyticsParameterItemName: contentName,
                    AnalyticsParameterContentType: contentType.rawValue,
                    KPConstants.Analytics.ParameterDuration: duration])
                Flurry.logEvent(AnalyticsEventViewItem, withParameters: [
                    AnalyticsParameterItemID: contentId,
                    AnalyticsParameterItemName: contentName,
                    AnalyticsParameterContentType: contentType.rawValue,
                    KPConstants.Analytics.ParameterDuration: duration])
                
            } catch {
                
            }
        }
    }
}
