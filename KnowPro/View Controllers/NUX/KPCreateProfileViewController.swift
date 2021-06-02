//
//  KPCreateProfileViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/12/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import AAPickerView
import Firebase

class KPCreateProfileViewController: UIViewController {
    
    var alertMsgs: [String] = ["Please enter your first name.", "Please enter your last name", "Please enter credential info.", "Please enter your Specialty."]
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var firstNameField: UITextField!
    @IBOutlet private weak var lastNameField: UITextField!
    @IBOutlet private weak var ageField: AAPickerView!
    @IBOutlet private weak var credentialField: AAPickerView!
    @IBOutlet private weak var specialtyField: AAPickerView!
    @IBOutlet private weak var otherSpecialtyField: UITextField!
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
        let formStatus = validateFroms();
        if(formStatus == 511){
            guard let user = Auth.auth().currentUser,
                let email = user.email else { return }
            
            Analytics.setUserProperty(ageField.text ?? "", forName: "age")
            Analytics.setUserProperty(credentialField.text ?? "", forName: "credential")
            Analytics.setUserProperty(specialtyField.text ?? "", forName: "specialty")
            
            let database = Firestore.firestore()
            
            database.collection("users").document(user.uid).setData([
                "firstName": firstNameField.text ?? "",
                "lastName": lastNameField.text ?? "",
                "age": ageField.text ?? "",
                "credential": credentialField.text ?? "",
                "specialty": (specialtyField.text ?? "") == "Other (please describe)" ?
                    (otherSpecialtyField.text ?? "") ?? "Other (please describe)" : specialtyField.text ?? "",
                "email": email
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
                    UserDefaults.standard.set(true, forKey: KPConstants.Defaults.ProfileComplete)
                    DispatchQueue.main.async {
                        if let parent = self.parent as? KPSignUpViewController {
                            parent.presentPracticeInfo()
                        }
                    }
                }
            }
        }else{
            self.showMessageAlert(temp: formStatus)
        }
      
    }
    
    func validateFroms() -> Int{
        if(firstNameField.text == nil || firstNameField.text == ""){
            return 0
        }
        
        if(lastNameField.text == nil || lastNameField.text == ""){
            return 1
        }
        
        if(credentialField.text == nil || credentialField.text == ""){
            return 2
        }
        
        if(specialtyField.text == nil || specialtyField.text == ""){
            return 3
        }
        
        
        return 511
    }
    
    func showMessageAlert(temp: Int){
        let alertController = UIAlertController(title: "KnowPro", message: self.alertMsgs[temp], preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
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
        
        configurePickers()
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
    
    private func configurePickers() {
        
        ageField.pickerType = .string(data: [
            "18 - 24",
            "25 - 34",
            "35 - 44",
            "45 - 54",
            "55 - 64",
            "65+"])
        ageField.toolbar.tintColor = UIColor(named: KPConstants.Color.GlobalBlack)
        ageField.tintColor = .clear
        
        credentialField.pickerType = .string(data: [
            "MD",
            "DO",
            "PA",
            "NP",
            "Clinical Staff",
            "Admin Staff",
            "Biologic Coordinator",
            "Aesthetician"])
        credentialField.toolbar.tintColor = UIColor(named: KPConstants.Color.GlobalBlack)
        credentialField.tintColor = .clear
        
        specialtyField.pickerType = .string(data: [
            "Dermatology",
            "Plastic Surgery",
            "Primary Care",
            "Aesthetics",
            "Pediatrics",
            "Rheumatology",
            "Other (please describe)"])
        specialtyField.toolbar.tintColor = UIColor(named: KPConstants.Color.GlobalBlack)
        specialtyField.tintColor = .clear
        specialtyField.valueDidSelected = { (index) in
            if self.specialtyField.text == "Other (please describe)" {
                DispatchQueue.main.async {
                    self.otherSpecialtyField.superview?.superview?.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: { self.view.layoutIfNeeded() })
                }
            } else {
                DispatchQueue.main.async {
                    self.otherSpecialtyField.superview?.superview?.isHidden = true
                    UIView.animate(withDuration: 0.2, animations: { self.view.layoutIfNeeded() })
                }
            }
        }
    }
    
    private func validateFields() -> Bool {
        var isValid = true

        let lengthError = KPValidationError(message: NSLocalizedString("Required Field", comment: ""))
        if !(firstNameField.text?.count ?? 0 > 0),
            let textField = firstNameField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(lastNameField.text?.count ?? 0 > 0),
            let textField = lastNameField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(ageField.text?.count ?? 0 > 0),
            let textField = ageField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(credentialField.text?.count ?? 0 > 0),
            let textField = credentialField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if !(specialtyField.text?.count ?? 0 > 0),
            let textField = specialtyField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        if specialtyField.text == "Other (please describe)",
            !(otherSpecialtyField.text?.count ?? 0 > 0),
            let textField = otherSpecialtyField.superview?.superview as? KPTextField {
            textField.displayError(lengthError)
            isValid = false
        }
        
        return isValid
    }

}

extension KPCreateProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameField:
            if let nextTextField = lastNameField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case lastNameField:
            if let nextTextField = ageField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case ageField:
            if let nextTextField = credentialField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case credentialField:
            if let nextTextField = specialtyField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case specialtyField:
            if specialtyField.text == "Other (please describe)" {
                if let nextTextField = otherSpecialtyField.superview?.superview as? KPTextField {
                    _ = nextTextField.becomeFirstResponder()
                }
            } else {
                continueButtonPressed(textField)
            }
        default:
            continueButtonPressed(textField)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == credentialField || textField == specialtyField || textField == ageField {
            return false
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
