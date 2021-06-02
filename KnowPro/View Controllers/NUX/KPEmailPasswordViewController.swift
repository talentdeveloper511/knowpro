//
//  KPEmailPasswordViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/12/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import Firebase
import Validator
import Atributika
import SafariServices

@IBDesignable
class KPEmailPasswordViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var introTextLabel: UILabel!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var privacyLabel: AttributedLabel!
    @IBOutlet weak var passwordRequirementsButton: UIButton!

    // MARK: - Controller Properties
    
    @IBInspectable private var isLogin: Bool = false
    
    // MARK: - Actions
    
    @IBAction private func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func signUpLoginPressed(_ sender: AnyObject) {
        if !isLogin {
            let loginController = UIStoryboard(name: "SignUpLogin", bundle: Bundle.main)
                .instantiateViewController(withIdentifier: "KPEmailPasswordViewController")
            if let viewControllers = navigationController?.viewControllers, let rootController = viewControllers.first {
                navigationController?.setViewControllers([rootController, loginController], animated: true)
            }
        } else {
            let signupController = UIStoryboard(name: "SignUpLogin", bundle: Bundle.main)
                .instantiateViewController(withIdentifier: "KPSignUpViewController")
            if let viewControllers = navigationController?.viewControllers, let rootController = viewControllers.first {
                navigationController?.setViewControllers([rootController, signupController], animated: true)
            }
        }
    }
    
    @IBAction private func continueButtonPressed(_ sender: AnyObject) {
        view.endEditing(true)
        
        if !isLogin {
            login()
        } else {
            createUser()
        }
    }
    
    @IBAction private func passwordRequirementsButtonPressed(_ sender: AnyObject) {
        let passwordRequirementsString = NSLocalizedString("""
Password must be at least eight characters, \
one uppercase letter, \
one lowercase letter, \
one number, \
and one special character
""", comment: "")
        let requirementsAlert = UIAlertController(title: NSLocalizedString("Password Requirements", comment: ""),
                                                  message: passwordRequirementsString,
                                                  preferredStyle: .alert)
        requirementsAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                                  style: .default,
                                                  handler: nil))
        present(requirementsAlert, animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signInButton.titleLabel?.letterSpace = 2
        switchButton.titleLabel?.letterSpace = 2
        switchButton.layoutIfNeeded()
        
        if !isLogin {
            let descriptionParagraphStyle = NSMutableParagraphStyle()
            descriptionParagraphStyle.lineSpacing = 1.5
            descriptionParagraphStyle.lineBreakMode = .byWordWrapping
            let descriptionAttributedText = NSAttributedString(string: introTextLabel.text ?? "",
                                                               attributes:
                [NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle])
            
            introTextLabel.attributedText = descriptionAttributedText
            
            privacyLabel.numberOfLines = 0
            let link = Style("a")
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .normal)
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .highlighted)
            let all = Style.font(.systemFont(ofSize: 12))
                .foregroundColor(.gray)
                .paragraphStyle(descriptionParagraphStyle)
            privacyLabel.attributedText = """
Upon sign up, you agree to the KnowPro \
<a href=\"https://knowproapp.com/termsandconditions/\">Terms of Service</a> and \
<a href=\"https://knowproapp.com/privacy-policy/\">Privacy Policy</a>.
""".style(tags: link).styleAll(all)
            view.layoutIfNeeded()
            
            privacyLabel.onClick = { label, detection in
                switch detection.type {
                case .tag(let tag):
                    if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                        let safariViewController = SFSafariViewController(url: url)
                        
                        safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
                        self.present(safariViewController, animated: true, completion: nil)
                    }
                default:
                    break
                }
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
        
        if isLogin {
            return isValid
        }
        
        let passwordError = KPValidationError(message: NSLocalizedString("Invalid Password", comment: ""))
        // swiftlint:disable:next line_length
        let passwordRule = ValidationRulePattern(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$", error: passwordError)
        
        if !passwordField.validate(rule: passwordRule).isValid {
            if let textField = passwordField.superview?.superview as? KPTextField {
                if !isLogin {
                    passwordRequirementsButton.isHidden = true
                }
                textField.displayError(passwordError)
                passwordRequirementsButtonPressed(passwordRequirementsButton)
                isValid = false
            }
        }
        
        let passwordMatchError = KPValidationError(message: NSLocalizedString("Password Doesn't Match", comment: ""))
        if passwordField.text != confirmPasswordField.text {
            if let textField = confirmPasswordField.superview?.superview as? KPTextField {
                textField.displayError(passwordMatchError)
                isValid = false
            }
        }
        
        return isValid
    }
    
    private func createUser() {
        guard let email = emailField.text, let password = passwordField.text, validateFields() else { return }

        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error == nil, let user = result?.user {
                
                user.isOnboardingComplete({ (complete, error) in
                    if error == nil && complete {
                        DispatchQueue.main.async {
                            let mainController = UIStoryboard(name: "Main", bundle: Bundle.main)
                                .instantiateViewController(withIdentifier: "KPTabBarController")
                            self.navigationController?.setViewControllers([mainController], animated: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            if let rootController = self.navigationController,
                                let firstController = rootController.viewControllers.first,
                                let onboardingController = UIStoryboard(name: "SignUpLogin", bundle: Bundle.main)
                                    .instantiateViewController(withIdentifier: "KPSignUpViewController")
                                    as? KPSignUpViewController {
                                rootController.setViewControllers([firstController, onboardingController],
                                                                  animated: true)
                            }
                        }
                    }
                })
                
            } else {
                let errorAlert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                                   message: error?.localizedDescription,
                                                   preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                                   style: .default,
                                                   handler: nil))
                DispatchQueue.main.async {
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func login() {
        guard let email = emailField.text, let password = passwordField.text, validateFields() else { return }

        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
            if error == nil {
                
                UserDefaults.standard.set(false, forKey: KPConstants.Defaults.OnboardingComplete)
                UserDefaults.standard.set(false, forKey: KPConstants.Defaults.PracticeInfoComplete)
                UserDefaults.standard.set(false, forKey: KPConstants.Defaults.ProfileComplete)
                
                DispatchQueue.main.async {
                    if let parent = self.parent as? KPSignUpViewController {
                        parent.presentCreateProfile()
                    }
                }
            } else {
                let errorAlert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                                   message: error?.localizedDescription,
                                                   preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                                   style: .default,
                                                   handler: nil))
                DispatchQueue.main.async {
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }

}

extension KPEmailPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            if let nextTextField = passwordField.superview?.superview as? KPTextField {
                _ = nextTextField.becomeFirstResponder()
            }
        case passwordField:
            if !isLogin {
                if let nextTextField = confirmPasswordField.superview?.superview as? KPTextField {
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField.superview?.superview as? KPTextField {
            textField.isActive = true
        }
        
        if textField == passwordField && !isLogin {
            passwordRequirementsButton.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField.superview?.superview as? KPTextField {
            textField.isActive = false
        }
    }
}
