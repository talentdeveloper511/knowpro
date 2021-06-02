//
//  KPOnboardingViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/13/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPOnboardingViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var createAccountButton: UIButton!
    @IBOutlet private weak var signInButton: UIButton!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createAccountButton.titleLabel?.letterSpace = 2
        signInButton.titleLabel?.letterSpace = 2
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
