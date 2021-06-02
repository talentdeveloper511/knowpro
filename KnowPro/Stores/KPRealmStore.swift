//
//  KPRealmStore.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/21/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence

enum Errors: Error {
    case invalidType(type: Any.Type)
}

class KPRealmStore: PersistenceStore {
    
    private var realm: Realm!
    private var realmQueue: DispatchQueue!
    
    func create<T>(type: Any.Type) throws -> T {
        if let `class` = type as? AnyClass {
            if let object = `class` as? Object.Type {
                let object = realm.create(object)
                if let object = object as? T {
                    return object
                }
            }
            
        }
        throw Errors.invalidType(type: type)
    }
    
    func fetchAll<T>(type: Any.Type, predicate: NSPredicate) throws -> [T] {
        if let `class` = type as? AnyClass {
            guard let `class` = `class` as? Object.Type else {
                throw Errors.invalidType(type: type)
            }
            let objects = realm.objects(`class`).filter(predicate)
            var array: [T] = []
            for item in objects {
                if let object = item as? T {
                    array.append(object)
                }
            }
            return array
        }
        throw Errors.invalidType(type: type)
        
    }
    
    func properties(for type: Any.Type) throws -> [String] {
        if let `class` = type as? AnyClass {
            if let object = `class` as? Object.Type {
                let properties = object.init().objectSchema.properties
                let filteredProperties = try properties.map { $0.description.components(separatedBy: " ").first
                    ?? $0.description }.filter {
                    try relationships(for: type).contains($0) == false
                }
                return filteredProperties
            }
        }
        
        throw Errors.invalidType(type: type)
    }
    
    func delete(type: Any.Type, predicate: NSPredicate) throws {
        let objects: [Object] = try fetchAll(type: type, predicate: predicate)
        objects.forEach {
            self.realm.delete($0)
        }
    }
    
    func relationships(for type: Any.Type) throws -> [String] {
        if let `class` = type as? AnyClass {
            if let object = `class` as? Object.Type {
                let relationShips = object.init().objectSchema.properties.filter {
                    let objectRelationShips = $0.type == PropertyType.object
                    let linkedObjectRelationShips = $0.type == PropertyType.linkingObjects
                    return objectRelationShips || linkedObjectRelationShips
                    }.map {
                        $0.description.components(separatedBy: " ").first ?? $0.description
                }
                return relationShips
            }
        }
        throw Errors.invalidType(type: type)
    }
    
    func save() throws {
        //try self.realm.commitWrite()
    }
    
    func performBlock(block: @escaping () -> Void) {
        self.performAndWait {
            block()
        }
    }
    
    func performAndWait(block: @escaping () -> Void) {
        if self.realmQueue == nil {
            self.realmQueue = DispatchQueue(label: "com.camber.KnowPro.realmQueue")
        }
        
        self.realmQueue.async {
            
            do {
                self.realm = try Realm()
                self.realm.beginWrite()
                block()
                try self.realm.commitWrite()
            } catch {
                
            }
            
        }
    }
    
    func syncToken() -> String? {
        
        do {
            let realm = try Realm()
            if let syncSpace = realm.objects(KPSyncSpace.self).first {
                return syncSpace.syncToken
            }
        } catch {
            
        }
        
        return nil
    }
}
