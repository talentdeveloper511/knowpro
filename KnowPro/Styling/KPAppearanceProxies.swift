//
//  KPAppearanceProxies.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/3/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPAppearanceProxies: NSObject {
    
    class func configureAppearanceProxies() {
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.backIndicatorImage = UIImage(named: "BackIcon")
        navigationBarAppearance.backIndicatorTransitionMaskImage = UIImage(named: "BackIcon")
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.shadowImage = UIImage()
        tabBarAppearance.clipsToBounds = true
        tabBarAppearance.layer.borderWidth = 0
        
        let tabBarItemApperance = UITabBarItem.appearance()
        tabBarItemApperance.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)],
                                                   for: .normal)
        
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -9001, vertical: 0),
                                                                     for: .default)
    }
}
