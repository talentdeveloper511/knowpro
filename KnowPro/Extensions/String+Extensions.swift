//
//  String+Extensions.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/10/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation

extension String {
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
}
