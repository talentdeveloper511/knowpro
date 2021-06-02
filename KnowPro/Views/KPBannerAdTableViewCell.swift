//
//  KPBannerAdTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/4/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPBannerAdTableViewCell: UITableViewCell {
    
    @IBOutlet weak var adButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        adButton.sd_imageTransition = .fade
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
