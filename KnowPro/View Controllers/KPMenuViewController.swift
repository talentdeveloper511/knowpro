//
//  KPMenuViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/11/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import SPLarkController
import MessageUI
import Firebase
import OneSignal

class KPMenuViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var signoutButton: UIButton!
    @IBOutlet private weak var pushNotificationSwitch: UISwitch!
    
    // MARK: - Actions
    
    @IBAction func dismissMenu(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pushNotificationToggleChanged(_ sender: UISwitch) {
        if OneSignal.getPermissionSubscriptionState()?.permissionStatus.status ?? .notDetermined == .authorized {
            OneSignal.setSubscription(sender.isOn)
            Auth.auth().currentUser?.syncPushTags(nil)
        } else {
            let pushAlert = UIAlertController(title:
                NSLocalizedString("Subscription Error", comment: ""),
                                                 message:
                NSLocalizedString(
"""
To subscribe to push notifications please navigate to your App Settings and manually enable push notifications.
""",
                                  comment: ""),
                                                 preferredStyle: .alert)
            pushAlert.addAction(UIAlertAction(title: NSLocalizedString("App Settings", comment: ""),
                                                 style: .default,
                                                 handler: { (_) in
                                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                                        if UIApplication.shared.canOpenURL(url) {
                                                            UIApplication.shared.open(url)
                                                        }
                                                    }
            }))
            pushAlert.addAction(UIAlertAction(title: NSLocalizedString("Later", comment: ""),
                                              style: .cancel,
                                              handler: nil))
            
            present(pushAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func feedbackPressed(_ sender: AnyObject) {
        if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/id1475538948?action=write-review&mt=8"), UIApplication.shared.canOpenURL(reviewURL) {
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func contactSupportPressed(_ sender: AnyObject) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let composeVC = MFMailComposeViewController()
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["contact@knowproapp.com"])
        composeVC.setSubject("KnowPro Support Request")
        composeVC.mailComposeDelegate = self
        
        // Present the view controller modally.
        present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func signoutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
        
        dismiss(animated: true) {
            if let navigationController = UIApplication.shared.topController() as? UINavigationController {
                let nuxController = UIStoryboard(name: "SignUpLogin", bundle: Bundle.main)
                    .instantiateViewController(withIdentifier: "KPOnboardingViewController")
                navigationController.setViewControllers([nuxController], animated: true)
            }
        }
        
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var signoutTitle = NSLocalizedString("Sign out", comment: "")
        if let email = Auth.auth().currentUser?.email {
            signoutTitle += " (\(email))"
        }
        signoutButton.titleLabel?.numberOfLines = 2
        signoutButton.setTitle(signoutTitle, for: .normal)
        if OneSignal.getPermissionSubscriptionState()?.permissionStatus.status ?? .notDetermined == .authorized {
            pushNotificationSwitch.isOn = OneSignal.getPermissionSubscriptionState()?
                .subscriptionStatus.userSubscriptionSetting == true
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

}

extension KPMenuViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
