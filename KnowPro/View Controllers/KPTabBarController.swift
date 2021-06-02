//
//  KPTabBarController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/3/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import OneSignal
import Firebase

class KPTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tabBar.unselectedItemTintColor = UIColor.init(named: KPConstants.Color.GlobalBlack)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            Auth.auth().currentUser?.syncPushTags(nil)
            print("User accepted notifications: \(accepted)")
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item == tabBar.selectedItem {
            NotificationCenter.default.post(KPConstants.Notifications.TabSelected)
        }
    }

}
