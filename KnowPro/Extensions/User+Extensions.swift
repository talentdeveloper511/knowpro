//
//  User+Extensions.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/13/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation
import Firebase
import OneSignal

extension User {
    
    func isOnboardingComplete(_ completion: @escaping ((Bool, Error?) -> Void)) {
        
        let database = Firestore.firestore()
        database.collection("users").document(uid).getDocument { (snapshot, error) in
            if error != nil {
                completion(false, error)
            } else if let user = snapshot?.data() {
                
                guard let age = user["age"] as? String, let firstName = user["firstName"] as? String,
                    let lastName = user["lastName"] as? String, let credential = user["credential"] as? String,
                    let specialty = user["specialty"] as? String, age.count > 0,
                    firstName.count > 0, lastName.count > 0,
                    credential.count > 0, specialty.count > 0 else {
                        UserDefaults.standard.set(false, forKey: KPConstants.Defaults.OnboardingComplete)
                        UserDefaults.standard.set(false, forKey: KPConstants.Defaults.PracticeInfoComplete)
                        UserDefaults.standard.set(false, forKey: KPConstants.Defaults.ProfileComplete)
                        completion(false, nil)
                        return
                }
                
                Analytics.setUserProperty(age, forName: "age")
                Analytics.setUserProperty(credential, forName: "credential")
                Analytics.setUserProperty(specialty, forName: "specialty")
                
                guard let street1 = user["street1"] as? String,
                    let city = user["city"] as? String,
                    let state = user["state"] as? String, let zip = user["zip"] as? String,
                    let practiceName = user["practiceName"] as? String,
                    let practicePhone = user["practicePhone"] as? String,
                    street1.count > 0, city.count > 0, state.count > 0, zip.count > 0,
                    practiceName.count > 0, practicePhone.count > 0 else {
                        UserDefaults.standard.set(false, forKey: KPConstants.Defaults.OnboardingComplete)
                        UserDefaults.standard.set(false, forKey: KPConstants.Defaults.PracticeInfoComplete)
                        UserDefaults.standard.set(true, forKey: KPConstants.Defaults.ProfileComplete)
                        completion(false, nil)
                        return
                }
                
                self.syncPushTags(user["following"] as? [String])
                
                UserDefaults.standard.set(true, forKey: KPConstants.Defaults.OnboardingComplete)
                UserDefaults.standard.set(true, forKey: KPConstants.Defaults.PracticeInfoComplete)
                UserDefaults.standard.set(true, forKey: KPConstants.Defaults.ProfileComplete)
                completion(true, nil)
            } else {
                UserDefaults.standard.set(false, forKey: KPConstants.Defaults.OnboardingComplete)
                UserDefaults.standard.set(false, forKey: KPConstants.Defaults.PracticeInfoComplete)
                UserDefaults.standard.set(false, forKey: KPConstants.Defaults.ProfileComplete)
                completion(false, nil)
            }
        }
    }
    
    func isFollowing(_ contentId: String, _ completion: @escaping ((Bool, Error?) -> Void)) {
        let database = Firestore.firestore()
        database.collection("users").document(uid).getDocument { (snapshot, error) in
            if error != nil {
                completion(false, error)
            } else if let user = snapshot?.data() {
                
                guard let following = user["following"] as? [String] else {
                        completion(false, nil)
                        return
                }
                
                completion(following.contains(contentId), nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func follow(_ contentId: String, _ completion: @escaping ((Bool, Error?) -> Void)) {
        let database = Firestore.firestore()
        database.collection("users").document(uid).getDocument { (snapshot, error) in
            if error != nil {
                completion(false, error)
            } else if let user = snapshot?.data() {
                
                var following: [String] = user["following"] as? [String] ?? []
                
                if !following.contains(contentId) {
                    following.append(contentId)
                }
                
                database.collection("users").document(self.uid).setData(["following": following], merge: true) { err in
                    if let err = err {
                        completion(false, err)
                    } else {
                        self.syncPushTags(following)
                        completion(true, nil)
                    }
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    func unfollow(_ contentId: String, _ completion: @escaping ((Bool, Error?) -> Void)) {
        let database = Firestore.firestore()
        database.collection("users").document(uid).getDocument { (snapshot, error) in
            if error != nil {
                completion(false, error)
            } else if let user = snapshot?.data() {
                
                var following: [String] = user["following"] as? [String] ?? []
                
                following.removeAll(where: { (followingId) -> Bool in
                    return followingId == contentId
                })
                
                database.collection("users").document(self.uid).setData(["following": following], merge: true) { err in
                    if let err = err {
                        completion(false, err)
                    } else {
                        self.syncPushTags(following)
                        completion(true, nil)
                    }
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    func syncPushTags(_ following: [String]?) {
        guard let following = following else {
            freshSyncPushTags()
            return
        }
        
        OneSignal.getTags({ (tags) in
            var tags = tags ?? [:]
            for tagKey in tags.keys {
                if let tagKey = tagKey as? String {
                    if !following.contains(tagKey) {
                        tags[tagKey] = ""
                    }
                }
            }
            
            for contentId in following {
                tags[contentId] = true
            }
            
            tags["Global"] = "True"
            OneSignal.sendTags(tags)
        })
    }
    
    private func freshSyncPushTags() {
        let database = Firestore.firestore()
        database.collection("users").document(uid).getDocument { (snapshot, _) in
            if let user = snapshot?.data(), let following = user["following"] as? [String] {
                self.syncPushTags(following)
            } else {
                OneSignal.sendTags(["Global": "True"])
            }
        }
    }
}
