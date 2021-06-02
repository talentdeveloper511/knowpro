//
//  KPInfoTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/24/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import Atributika

class KPInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: AttributedLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
