//
//  KPGalleryCollectionViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/20/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var galleryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

        galleryImageView.sd_imageTransition = .fade
        galleryImageView.image = defaultPlaceholderColor?.image()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

        galleryImageView.image = defaultPlaceholderColor?.image()
    }
}
