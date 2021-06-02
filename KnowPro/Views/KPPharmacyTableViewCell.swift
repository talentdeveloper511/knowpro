//
//  KPPharmacyTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/24/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import MapKit

class KPPharmacyTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var pharmacyImageView: UIImageView!
    @IBOutlet private weak var pharmacyBackgroundView: UIView!
    @IBOutlet private weak var coveredPricingLabel: UILabel!
    @IBOutlet private weak var uncoveredPricingLabel: UILabel!
    @IBOutlet private weak var contactTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        let defaultColor = UIColor(named: KPConstants.Color.GlobalBlack)
        
        pharmacyBackgroundView.layer.shadowColor = defaultColor?.cgColor
        pharmacyBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 8)
        pharmacyBackgroundView.layer.shadowRadius = 16
        pharmacyBackgroundView.layer.shadowOpacity = 0.1
        
        pharmacyImageView.sd_imageTransition = .fade
        pharmacyImageView.image = defaultPlaceholderColor?.image()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        pharmacyImageView.image = defaultPlaceholderColor?.image()
    }
    
    func configure(_ pharmacy: KPPharmacy, _ pricing: KPPricing?) {
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        pharmacyImageView.sd_setImage(with: pharmacy.logoURL(),
                                      placeholderImage: defaultPlaceholderColor?.image())
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        
        coveredPricingLabel.text = pricing?.coveredRange ?? "N/A"
        uncoveredPricingLabel.text = pricing?.notCoveredRange ?? "N/A"
        
        contactTextView.text = pharmacy.contactInfo()
    }
}
