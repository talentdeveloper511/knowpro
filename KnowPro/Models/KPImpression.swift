//
//  KPImpression.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/16/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift

enum KPContentType: String {
    case advertisement
    case article
    case company
    case drug
}

class KPImpression: Object {
    
    @objc dynamic var userId: String?
    @objc dynamic var contentId: String?

    let convertedView = RealmOptional<Bool>()
}
