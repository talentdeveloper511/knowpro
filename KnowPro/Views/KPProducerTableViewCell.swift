//
//  KPProducerTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/24/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPProducerTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var producerImageView: UIImageView!
    @IBOutlet private weak var producerBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        producerBackgroundView.layer.shadowColor = defaultColor?.cgColor
        producerBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 8)
        producerBackgroundView.layer.shadowRadius = 16
        producerBackgroundView.layer.shadowOpacity = 0.1
        
        producerImageView.sd_imageTransition = .fade
        producerImageView.image = defaultPlaceholderColor?.image()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        producerBackgroundView.layer.shadowColor = defaultColor?.cgColor
        producerImageView.image = defaultPlaceholderColor?.image()
    }
    
    func configure(_ drug: KPDrug) {
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        producerImageView.sd_setImage(with: drug.producer?.largeLogoURL(),
                                  placeholderImage: defaultPlaceholderColor?.image())
        
        if let secondaryColor = drug.secondaryColor {
            let hexColor = UIColor(hexFromString: secondaryColor)
            producerBackgroundView.layer.shadowColor = hexColor.cgColor
        } else {
            let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
            producerBackgroundView.layer.shadowColor = defaultColor?.cgColor
        }
    }

}
