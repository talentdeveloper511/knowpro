//
//  KPContactViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/10/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

enum KPContactType: String {
    case email
    case phone
    case website
}

protocol KPContactViewControllerDelegate: class {
    func didPressContactButton()
}

class KPContactViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var contactIconView: UIImageView!
    @IBOutlet private weak var contactTitleLabel: UILabel!
    @IBOutlet private weak var contactButton: UIButton!
    @IBOutlet private weak var contactButtonGradientView: KPContactGradientView!
    @IBOutlet private weak var contactBodyLabel: UILabel!
    
    // MARK: - Controller Properties
    
    var contactString: String? {
        didSet {
            configureContactType()
        }
    }
    var companyTitle: String?
    var contactIcon: UIImage?
    var contactTitle: String?
    var contactStartingColor: UIColor?
    var contactEndingColor: UIColor?
    var contactPrimaryColor: UIColor?
    private var contactType: KPContactType?
    weak var contactViewControllerDelegate: KPContactViewControllerDelegate?
    
    // MARK: - Actions
    
    @IBAction private func contactButtonPressed(_ sender: AnyObject) {

        dismiss(animated: true) {
            self.contactViewControllerDelegate?.didPressContactButton()
        }
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureViews()
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
    
    private func configureViews() {
        if let contactIcon = contactIcon {
            contactIconView.image = contactIcon
        }
        
        contactTitleLabel.text = contactTitle
        contactTitleLabel.textColor = contactPrimaryColor
        
        let contactBodyString = """
        \(companyTitle ?? NSLocalizedString("Company", comment: "")) \
        \(NSLocalizedString("reps are ready to assist you with your request via", comment: "")) \
        \(contactType?.rawValue ?? "website") \(NSLocalizedString("at", comment: ""))
        \(contactString ?? "")
        """
        
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineSpacing = 1.5
        descriptionParagraphStyle.lineBreakMode = .byWordWrapping
        descriptionParagraphStyle.alignment = .center
        
        let descriptionAttributedText = NSMutableAttributedString(string: contactBodyString,
                                                           attributes:
            [NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
             NSAttributedString.Key.foregroundColor: UIColor(named: KPConstants.Color.GlobalBlack)!])
        
        if let contactStringRange = contactBodyString.range(of: contactString ?? "") {
            descriptionAttributedText.addAttributes(
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                 NSAttributedString.Key.foregroundColor: contactPrimaryColor ??
                    UIColor(named: KPConstants.Color.GlobalBlack)!],
                range: contactBodyString.nsRange(from: contactStringRange))
        }
        
        contactBodyLabel.attributedText = descriptionAttributedText
        
        switch contactType ?? .website {
        case .email:
            contactButton.setTitle(NSLocalizedString("COMPOSE EMAIL", comment: ""), for: .normal)
        case .phone:
            let buttonTitle = "\(NSLocalizedString("CALL", comment: "")) \(contactString ?? "")"
            contactButton.setTitle(buttonTitle, for: .normal)
        case .website:
            contactButton.setTitle(NSLocalizedString("OPEN BROWSER", comment: ""), for: .normal)
        }
        
        contactButton.titleLabel?.letterSpace = 2
        contactButtonGradientView.gradientStartingColor = contactStartingColor
        contactButtonGradientView.gradientEndingColor = contactEndingColor
    }
    
    private func configureContactType() {
        guard let contactString = contactString else { return }
        
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link]
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            detector.enumerateMatches(in: contactString,
                                      options: [],
                                      range: NSRange(location: 0,
                                                     length: contactString.count)) { (result, _, _) in
                if result?.resultType == .phoneNumber {
                    contactType = .phone
                } else if result?.resultType == .link {
                    if result?.url?.scheme == "mailto" {
                        contactType = .email
                    } else {
                        contactType = .website
                    }
                }
            }
        } catch {
            contactType = .website
        }
    }
}
