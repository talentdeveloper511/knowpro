//
//  UIScrollView+Extensions.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/25/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width))/self.frame.width)
    }
}
