//
//  KPCompanyCollectionViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/26/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPCompanyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var companyImageView: UIImageView!
    @IBOutlet private weak var companyBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        companyBackgroundView.layer.shadowColor = defaultColor?.cgColor
        companyBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 8)
        companyBackgroundView.layer.shadowRadius = 16
        companyBackgroundView.layer.shadowOpacity = 0.1
        
        companyImageView.sd_imageTransition = .fade
        companyImageView.image = defaultPlaceholderColor?.image()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        companyBackgroundView.layer.shadowColor = defaultColor?.cgColor
        companyImageView.image = defaultPlaceholderColor?.image()
    }
    
    func configure(_ company: KPCompany) {
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        companyImageView.sd_setImage(with: company.largeLogoURL(),
                                      placeholderImage: defaultPlaceholderColor?.image())
        
        if let secondaryColor = company.secondaryColor {
            let hexColor = UIColor(hexFromString: secondaryColor)
            companyBackgroundView.layer.shadowColor = hexColor.cgColor
        } else {
            let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
            companyBackgroundView.layer.shadowColor = defaultColor?.cgColor
        }
    }
}
