//
//  KPSignUpViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/12/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import Firebase

class KPSignUpViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - Controller Properties
    
    private weak var emailPasswordController: KPEmailPasswordViewController?
    private weak var createProfileController: KPCreateProfileViewController?
    private weak var practiceInfoController: KPPracticeInfoViewController?
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for child in children {
            if let emailPasswordController = child as? KPEmailPasswordViewController {
                self.emailPasswordController = emailPasswordController
            } else if let createProfileController = child as? KPCreateProfileViewController {
                self.createProfileController = createProfileController
            } else if let practiceInfoController = child as? KPPracticeInfoViewController {
                self.practiceInfoController = practiceInfoController
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            if UserDefaults.standard.bool(forKey: KPConstants.Defaults.ProfileComplete) {
                presentPracticeInfo()
            } else {
                presentCreateProfile()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Public Methods
    
    func presentCreateProfile(_ animated: Bool = true) {
        guard let createProfileController = createProfileController,
            let frame = createProfileController.view.superview?.frame else { return }
        
        if animated {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                self.scrollView.contentOffset = frame.origin
            }, completion: nil)
        } else {
            self.scrollView.contentOffset = frame.origin
        }
    }
    
    func presentPracticeInfo(_ animated: Bool = true) {
        guard let practiceInfoController = practiceInfoController,
            let frame = practiceInfoController.view.superview?.frame else { return }
        
        if animated {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                self.scrollView.contentOffset = frame.origin
            }, completion: nil)
        } else {
            self.scrollView.contentOffset = frame.origin
        }
    }
    
    func dismissNUX() {
        if let mainController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() {
            navigationController?.setViewControllers([mainController], animated: true)
        }
    }

}
