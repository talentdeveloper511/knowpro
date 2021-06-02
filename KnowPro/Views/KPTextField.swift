//
//  KPTextField.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/13/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPTextField: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Public Properties
    
    var isActive: Bool = false {
        
        didSet {
            let globalBlack = UIColor(named: KPConstants.Color.GlobalBlack)
            let globalYellow = UIColor(named: KPConstants.Color.GlobalYellow)
            let separatorGrey = UIColor(named: KPConstants.Color.SeparatorGrey)
            titleLabel.textColor = isActive ? globalYellow : globalBlack
            containerView.layer.borderColor = isActive ? globalYellow?.cgColor : separatorGrey?.cgColor
            containerView.layer.shadowColor = isActive ? globalYellow?.cgColor : UIColor.clear.cgColor
            errorLabel.isHidden = true
        }
    }
    
    override func resignFirstResponder() -> Bool {
        
        isActive = false
        
        return textField.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        
        isActive = true
        
        return textField.becomeFirstResponder()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.letterSpace = 2
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor(named: KPConstants.Color.SeparatorGrey)?.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowColor = UIColor.clear.cgColor
        containerView.layer.shadowOpacity = 0.24
        containerView.layer.shadowRadius = 8
    }
    
    func displayError(_ error: KPValidationError) {
        errorLabel.text = error.message
        errorLabel.isHidden = false
        containerView.layer.borderColor = UIColor(named: KPConstants.Color.LogoRed)?.cgColor
    }

}
