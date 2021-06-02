//
//  StringProtocol+Extensions.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/10/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation

extension StringProtocol where Index == String.Index {
    
    func nsRange(from range: Range<Index>) -> NSRange {
        
        return NSRange(range, in: self)
    }
}
