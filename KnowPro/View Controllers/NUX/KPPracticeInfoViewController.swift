//
//  KPPracticeInfoViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/12/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import Firebase
import PhoneNumberKit

class KPPracticeInfoViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var practiceNameField: UITextField!
    @IBOutlet private weak var streetField: UITextField!
    @IBOutlet private weak var street2Field: UITextField!
    @IBOutlet private weak var cityField: UITextField!
    @IBOutlet private weak var stateField: UITextField!
    @IBOutlet private weak var zipField: UITextField!
    @IBOutlet private weak var phoneNumberField: UITextField!
    @IBOutlet private weak var cellNumberField: UITextField!
    @IBOutlet private weak var introTextLabel: UILabel!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction private func backButtonPressed(_ sender: AnyObject) {
        try? Auth.auth().signOut()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func continueButtonPressed(_ sender: AnyObject) {
        view.endEditing(true)
        
        if(stateField.text == nil || stateField.text == ""){
            let alertController = UIAlertController(title: "KnowPro", message: "Please enter your state info.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }else{
            guard let user = Auth.auth().currentUser,
                validateFields() else { return }
            
            let database = Firestore.firestore()
            
            database.collection("users").document(user.uid).setData([
                "practiceName": practiceNameField.text ?? "",
                "street1": streetField.text ?? "",
                "street2": street2Field.text ?? "",
                "city": cityField.text ?? "",
                "state": stateField.text ?? "",
                "zip": zipField.text ?? "",
                "practicePhone": phoneNumberField.text ?? "",
                "cell": cellNumberField.text ?? ""
            ], merge: true) { err in
                if let err = err {
                    let errorAlert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                                       message: err.localizedDescription,
                                                       preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                                       style: .default,
                                                       handler: nil))
                    DispatchQueue.main.async {
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                } else {
                    UserDefaults.standard.set(true, forKey: KPConstants.Defaults.PracticeInfoComplete)
                    UserDefaults.standard.set(true, forKey: KPConstants.Defaults.OnboardingComplete)
                    
                    DispatchQueue.main.async {
                        let mainController = UIStoryboard(name: "Main", bundle: Bundle.main)
                            .instantiateViewController(withIdentifier: "KPTabBarController")
                        self.navigationController?.setViewControllers([mainController], animated: true)
                    }
                }
            }
        }
        

    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        continueButton.titleLabel?.letterSpace = 2
        headerLabel.letterSpace = 2
        
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
        
        /*let lengthError = KPValidationError(message: NSLocalizedString("Required Field", comment: ""))
        if !(practiceNameField.text?.count ?? 0 > 0),
            let textField = practiceNameField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(streetField.text?.count ?? 0 > 0),
            let textField = streetField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(cityField.text?.count ?? 0 > 0),
            let textField = cityField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(stateField.text?.count ?? 0 > 0),
            let textField = stateField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(zipField.text?.count ?? 0 > 0),
            let textField = zipField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(phoneNumberField.text?.count ?? 0 > 0),
            let textField = phoneNumberField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }*/
        
        let phoneError = KPValidationError(message: NSLocalizedString("Invalid Phone Number", comment: ""))
        if phoneNumberField.text?.count ?? 0 > 0,
            !validatePhoneNumber(phoneNumberField.text),
            let textField = phoneNumberField.superview?.superview as? KPTextField {
            textField.displayError(phoneError)
            isValid = false
        }
        
        if cellNumberField.text?.count ?? 0 > 0,
            !validatePhoneNumber(cellNumberField.text),
            let textField = cellNumberField.superview?.superview as? KPTextField {
            textField.displayError(phoneError)
            isValid = false
        }
        
        return isValid
    }
    
    private func validatePhoneNumber(_ text: String?) -> Bool {
        var isValid = true
        do {
            let phoneNumber = try PhoneNumberKit().parse(text ?? "")
            
            if phoneNumber.numberString.count == 0 {
                isValid = false
            }
        } catch {
            isValid = false
        }
        
        return isValid
    }
}

extension KPPracticeInfoViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case practiceNameField:
            if let nextTextField = streetField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case streetField:
            if let nextTextField = street2Field.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case street2Field:
            if let nextTextField = cityField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case cityField:
            if let nextTextField = stateField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case stateField:
            if let nextTextField = zipField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case zipField:
            if let nextTextField = phoneNumberField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case phoneNumberField:
            if let nextTextField = cellNumberField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        default:
            continueButtonPressed(textField)
        }
        
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
