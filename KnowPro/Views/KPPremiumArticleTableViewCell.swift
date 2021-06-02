//
//  KPPremiumArticleTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/4/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import OpenGraph

class KPPremiumArticleTableViewCell: KPArticleTableViewCell {
    
    @IBOutlet private weak var articleImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        articleImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        articleImageView.sd_imageTransition = .fade
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        articleImageView.sd_cancelCurrentImageLoad()
        articleImageView.image = defaultPlaceholderColor?.image()
    }
    
    override func configure(_ article: KPArticle, _ advertisement: KPAdvertisement?) {
        super.configure(article, advertisement)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

        if let imageURL = article.imageURL() {
            articleImageView.sd_setImage(with: imageURL,
                                         placeholderImage: defaultPlaceholderColor?.image())
        } else {
            articleImageView.image = defaultPlaceholderColor?.image()
            if let url = URL(string: article.link ?? "") {
                OpenGraph.fetch(url: url) { (results, _) in
                    if let results = results {
                        if let image = results[.image], let imageURL = URL(string: image) {
                            self.articleImageView.sd_setImage(with: imageURL,
                                                              placeholderImage: defaultPlaceholderColor?.image())
                        }
                    }
                }
            }
        }
    }

}
