//
//  KPSyncSpace.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/21/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import ContentfulPersistence

class KPSyncSpace: Object, SyncSpacePersistable {
    @objc dynamic var syncToken: String?
}
