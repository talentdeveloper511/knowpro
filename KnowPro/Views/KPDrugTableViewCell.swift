//
//  KPDrugTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/20/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPDrugTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var drugContainerView: UIView!
    @IBOutlet private weak var drugTitleLabel: UILabel!
    @IBOutlet private weak var drugDescriptionLabel: UILabel!
    @IBOutlet private weak var drugImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        drugContainerView.layer.shadowColor = defaultColor?.cgColor
        drugContainerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        drugContainerView.layer.shadowRadius = 16
        drugContainerView.layer.shadowOpacity = 0.1
        
        drugImageView.sd_imageTransition = .fade
        drugImageView.image = defaultPlaceholderColor?.image()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        drugContainerView.layer.shadowColor = defaultColor?.cgColor
        drugImageView.image = defaultPlaceholderColor?.image()
    }

    func configure(_ drug: KPDrug) {
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        drugImageView.sd_setImage(with: drug.smallLogoURL(),
                                   placeholderImage: defaultPlaceholderColor?.image())
        
        if let secondaryColor = drug.secondaryColor {
            let hexColor = UIColor(hexFromString: secondaryColor)
            drugContainerView.layer.shadowColor = hexColor.cgColor
        } else {
            let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
            drugContainerView.layer.shadowColor = defaultColor?.cgColor
        }
        
        configureTextContent(drug)
    }
    
    func configure(_ company: KPCompany) {
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        drugImageView.sd_setImage(with: company.smallLogoURL(),
                                  placeholderImage: defaultPlaceholderColor?.image())
        
        if let secondaryColor = company.secondaryColor {
            let hexColor = UIColor(hexFromString: secondaryColor)
            drugContainerView.layer.shadowColor = hexColor.cgColor
        } else {
            let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
            drugContainerView.layer.shadowColor = defaultColor?.cgColor
        }
        
        configureTextContent(company)
    }
    
    private func configureTextContent(_ drug: KPDrug) {
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.lineSpacing = 1.5
        titleParagraphStyle.lineBreakMode = .byTruncatingTail
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineSpacing = 1.5
        descriptionParagraphStyle.lineBreakMode = .byTruncatingTail
        
        let titleAttributedText = NSAttributedString(string: drug.name ?? "",
                                                            attributes:
            [NSAttributedString.Key.paragraphStyle: titleParagraphStyle])
        let descriptionAttributedText = NSAttributedString(string: drug.info ?? "",
                                                                  attributes:
            [NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle])
        
        drugTitleLabel.attributedText = titleAttributedText
        drugDescriptionLabel.attributedText = descriptionAttributedText
    }
    
    private func configureTextContent(_ company: KPCompany) {
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.lineSpacing = 1.5
        titleParagraphStyle.lineBreakMode = .byTruncatingTail
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineSpacing = 1.5
        descriptionParagraphStyle.lineBreakMode = .byTruncatingTail
        
        let titleAttributedText = NSAttributedString(string: company.name ?? "",
                                                     attributes:
            [NSAttributedString.Key.paragraphStyle: titleParagraphStyle])
        let descriptionAttributedText = NSAttributedString(string: company.info ?? "",
                                                           attributes:
            [NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle])
        
        drugTitleLabel.attributedText = titleAttributedText
        drugDescriptionLabel.attributedText = descriptionAttributedText
    }
}
