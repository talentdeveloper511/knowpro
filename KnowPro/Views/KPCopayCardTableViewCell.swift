//
//  KPCopayCardTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/24/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPCopayCardTableViewCell: UITableViewCell {

    @IBOutlet weak var copayCardImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        copayCardImageView.sd_imageTransition = .fade
        copayCardImageView.image = defaultPlaceholderColor?.image()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        copayCardImageView.image = defaultPlaceholderColor?.image()
    }
    
    func configure(_ drug: KPDrug) {
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        copayCardImageView.sd_setImage(with: drug.copayCardURL(),
                                      placeholderImage: defaultPlaceholderColor?.image())
    }

}
