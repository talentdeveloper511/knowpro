//
//  KPForgotPasswordViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/18/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import Firebase
import Validator

class KPForgotPasswordViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var introTextLabel: UILabel!
    
    // MARK: - Actions
    
    @IBAction private func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func forgotPasswordButtonPressed(_ sender: AnyObject) {
        view.endEditing(true)
        
        guard let email = emailField.text, validateFields() else { return }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                let errorAlert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                                   message:
                    NSLocalizedString("No account found for this email.", comment: ""),
                                                   preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                                   style: .default,
                                                   handler: nil))
                DispatchQueue.main.async {
                    self.present(errorAlert, animated: true, completion: nil)
                }
            } else {
                let successAlert = UIAlertController(title:
                    NSLocalizedString("Password Reset Instructions Sent", comment: ""),
                                                   message:
                    NSLocalizedString("Please check your email for instructions to complete your password reset.",
                                      comment: ""),
                                                   preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                                     style: .default,
                                                     handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                DispatchQueue.main.async {
                    self.present(successAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        forgotPasswordButton.titleLabel?.letterSpace = 2

        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineSpacing = 1.5
        descriptionParagraphStyle.lineBreakMode = .byWordWrapping
        let descriptionAttributedText = NSAttributedString(string: introTextLabel.text ?? "",
                                                           attributes:
            [NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle])
        
        introTextLabel.attributedText = descriptionAttributedText
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Private Methods
    
    private func validateFields() -> Bool {
        var isValid = true
        
        let emailError = KPValidationError(message: NSLocalizedString("Invalid Email Address", comment: ""))
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: emailError)
        if !emailField.validate(rule: emailRule).isValid {
            if let textField = emailField.superview?.superview as? KPTextField {
                textField.displayError(emailError)
                isValid = false
            }
        }
        
        return isValid
    }
}

extension KPForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        forgotPasswordButtonPressed(textField)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField.superview?.superview as? KPTextField {
            textField.isActive = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField.superview?.superview as? KPTextField {
            textField.isActive = false
        }
    }
}
