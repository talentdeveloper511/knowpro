//
//  KPContentfulStore.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/21/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import Contentful
import ContentfulPersistence
import RealmSwift
import OpenGraph

class KPContentfulStore: NSObject {
    
    static let sharedStore = KPContentfulStore()
    
    private var client: Client!
    private var store: KPRealmStore!
    private var syncManager: SynchronizationManager!
    
    override init() {
        super.init()
        
        if let entryTypes = [
            KPAdvertisement.self,
            KPArticle.self,
            KPCompany.self,
            KPContraindication.self,
            KPDosageInstruction.self,
            KPDrug.self,
            KPGeneralInformation.self,
            KPIndication.self,
            KPPharmacy.self,
            KPPrecaution.self,
            KPPricing.self,
            KPReferences.self
            ] as? [EntryPersistable.Type] {

            self.store = KPRealmStore()
            let persistenceModel = PersistenceModel(spaceType: KPSyncSpace.self,
                                                    assetType: KPAsset.self,
                                                    entryTypes: entryTypes)
            
            #if DEVELOPMENT
            self.client = Client(spaceId: KPConstants.Contentful.SpaceID,
                                 environmentId: "development",
                                 accessToken: KPConstants.Contentful.AccessToken)
            #else
            self.client = Client(spaceId: KPConstants.Contentful.SpaceID,
                                 accessToken: KPConstants.Contentful.AccessToken)
            #endif
            
            self.syncManager = SynchronizationManager(client: self.client,
                                                      localizationScheme: LocalizationScheme.all,
                                                      persistenceStore: self.store,
                                                      persistenceModel: persistenceModel)
        }
    }
    
    func sync(_ completion: (() -> Void)?) {
        
        self.syncManager.sync { (result) in
            print("Sync complete. Realm location is: \(Realm.Configuration.defaultConfiguration.fileURL!)")
            if let error = result.error {
                print("Error from sync: \(error.localizedDescription)")
            }
            
            DispatchQueue.global(qos: .utility).async {
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        for article in realm.objects(KPArticle.self) {
                            if article.promoted.value == nil {
                                article.promoted.value = false
                            }
                            
                            if article.imageURL() == nil || article.source == nil {
                                self.syncOpenGraph(article.id, article.link)
                            }
                        }
                    }
                    
                } catch {
                    
                }
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    private func syncOpenGraph(_ articleId: String, _ link: String?) {
        guard let link = link else { return }
        
        if let url = URL(string: link) {
            OpenGraph.fetch(url: url) { (results, _) in
                if let results = results {
                    if let source = results[.siteName] {
                        DispatchQueue.global(qos: .utility).async {
                            do {
                                let realm = try Realm()
                                
                                if let article = realm.objects(KPArticle.self).filter(NSPredicate(format: "id == %@", articleId)).first {
                                    try realm.write {
                                        article.source = source
                                    }
                                }
                                
                            } catch {
                                
                            }
                        }
                    }
                    
                    if let image = results[.image] {
                        DispatchQueue.global(qos: .utility).async {
                            do {
                                let realm = try Realm()
                                
                                if let article = realm.objects(KPArticle.self).filter(NSPredicate(format: "id == %@", articleId)).first {
                                    try realm.write {
                                        article.imageUrl = image
                                    }
                                }
                                
                            } catch {
                                
                            }
                        }
                    }
                }
            }
        }
    }
}
