//
//  KPContactTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/24/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contactContainerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        contactContainerView.layer.shadowRadius = 16
        contactContainerView.layer.shadowOpacity = 0.1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
