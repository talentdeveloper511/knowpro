//
//  UIApplication+Extensions.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/8/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    func topController() -> UIViewController? {
        
        var topController = keyWindow?.rootViewController
        
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        
        return topController
    }
}
