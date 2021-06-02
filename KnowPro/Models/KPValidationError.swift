//
//  KPValidationError.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/14/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation
import Validator

struct KPValidationError: Error, ValidationError {
    
    public let message: String
    
    public init(message: String) {
        
        self.message = message
    }
}
