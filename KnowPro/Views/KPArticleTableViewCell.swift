//
//  KPArticleTableViewCell.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/4/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import SDWebImage
import DateToolsSwift
import Firebase
import OpenGraph
import FavIcon

protocol KPArticleTableViewCellDelegate: class {
    func followingStatusChanged(_ cell: KPArticleTableViewCell)
    func sponsorButtonTapped(_ article: KPArticle?)
    func advertisementTapped(_ link: String, _ advertisement: KPAdvertisement?)
}

class KPArticleTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var topicImageView: UIImageView!
    @IBOutlet private weak var topicTitleLabel: UILabel!
    @IBOutlet private weak var topicPromotedLabel: UILabel!
    @IBOutlet private weak var followButton: UIButton!
    @IBOutlet private weak var unfollowButton: UIButton!
    @IBOutlet private weak var articleContainerView: UIView!
    @IBOutlet private weak var articleTitleLabel: UILabel!
    @IBOutlet private weak var articleDescriptionLabel: UILabel!
    @IBOutlet private weak var sourceImageView: UIImageView!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var advertisementButton: UIButton!
    
    weak var delegate: KPArticleTableViewCellDelegate?
    var article: KPArticle?
    var advertisement: KPAdvertisement?
    
    @IBAction private func followButtonTapped(_ sender: AnyObject) {
        followButton.isHidden = true
        
        if let contentId = article?.drug?.id {
            Auth.auth().currentUser?.follow(contentId, { (_, err) in
                if err != nil {
                    self.followButton.isHidden = false
                } else {
                    self.delegate?.followingStatusChanged(self)
                }
            })
        } else if let contentId = article?.author?.id {
            Auth.auth().currentUser?.follow(contentId, { (_, err) in
                if err != nil {
                    self.followButton.isHidden = false
                } else {
                    self.delegate?.followingStatusChanged(self)
                }
            })
        }
        
    }
    
    @IBAction private func unfollowButtonTapped(_ sender: AnyObject) {
        let unfollowActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let unfollowString = NSLocalizedString("Unfollow", comment: "") +
        " \(article?.drug?.name ?? article?.author?.name ?? "")"
        unfollowActionSheet.addAction(UIAlertAction(title: unfollowString, style: .destructive, handler: { (_) in
            self.followButton.isHidden = false
            
            if let contentId = self.article?.drug?.id {
                Auth.auth().currentUser?.unfollow(contentId, { (_, err) in
                    if err != nil {
                        self.followButton.isHidden = true
                    } else {
                        self.delegate?.followingStatusChanged(self)
                    }
                })
            } else if let contentId = self.article?.author?.id {
                Auth.auth().currentUser?.unfollow(contentId, { (_, err) in
                    if err != nil {
                        self.followButton.isHidden = true
                    } else {
                        self.delegate?.followingStatusChanged(self)
                    }
                })
            }
        }))
        unfollowActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                                    style: .cancel,
                                                    handler: nil))
        
        UIApplication.shared.topController()?.present(unfollowActionSheet, animated: true, completion: nil)
    }
    
    @IBAction private func sponsorButtonTapped(_ sender: AnyObject) {
        delegate?.sponsorButtonTapped(article)
    }
    
    @IBAction private func advertisementTapped(_ sender: AnyObject) {
        if let link = advertisement?.link {
            delegate?.advertisementTapped(link, advertisement)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

        articleContainerView.layer.shadowColor = defaultColor?.cgColor
        articleContainerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        articleContainerView.layer.shadowRadius = 16
        articleContainerView.layer.shadowOpacity = 0.1
        followButton.setBackgroundImage(defaultColor?.image(), for: .normal)
        
        topicImageView.sd_imageTransition = .fade
        sourceImageView.sd_imageTransition = .fade
        followButton.titleLabel?.letterSpace = 2
        
        topicImageView.image = defaultPlaceholderColor?.image()
        sourceImageView.image = defaultPlaceholderColor?.image()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

        topicImageView.sd_cancelCurrentImageLoad()
        sourceImageView.sd_cancelCurrentImageLoad()
        articleContainerView.layer.shadowColor = defaultColor?.cgColor
        followButton.setBackgroundImage(defaultColor?.image(), for: .normal)
        topicImageView.image = defaultPlaceholderColor?.image()
        sourceImageView.image = defaultPlaceholderColor?.image()
        followButton.isHidden = true
        unfollowButton.isHidden = true
    }
    
    func configure(_ article: KPArticle, _ advertisement: KPAdvertisement?) {
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        self.article = article
        self.advertisement = advertisement
        // TODO: Re-enable follow buttons once we get to the Favorites tab
        //self.followButton.isHidden = article.drug == nil && article.author == nil
        //self.unfollowButton.isHidden = article.drug == nil && article.author == nil

        if let drug = article.drug {
            topicImageView.sd_setImage(with: drug.smallLogoURL(),
                                       placeholderImage: defaultPlaceholderColor?.image())
            topicTitleLabel.text = drug.name
            
            if let secondaryColor = drug.secondaryColor {
                let hexColor = UIColor(hexFromString: secondaryColor)
                articleContainerView.layer.shadowColor = hexColor.cgColor
                followButton.setBackgroundImage(hexColor.image(), for: .normal)
            } else {
                let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
                articleContainerView.layer.shadowColor = defaultColor?.cgColor
                followButton.setBackgroundImage(defaultColor?.image(), for: .normal)
            }
            
            // TODO: Re-enable follow buttons once we get to the Favorites tab
            /*Auth.auth().currentUser?.isFollowing(drug.id, { (following, _) in
                self.followButton.isHidden = following
            })*/
        } else {
            if article.author != nil {
                topicImageView.sd_setImage(with: article.author?.smallLogoURL(),
                                           placeholderImage: defaultPlaceholderColor?.image())
            } else {
                topicImageView.image = UIImage(named: "LogoColorIcon")
            }
            
            topicTitleLabel.text = article.author?.name ?? "KnowPro NewsWire"
            
            if let secondaryColor = article.author?.secondaryColor {
                let hexColor = UIColor(hexFromString: secondaryColor)
                articleContainerView.layer.shadowColor = hexColor.cgColor
                followButton.setBackgroundImage(hexColor.image(), for: .normal)
            } else {
                let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
                articleContainerView.layer.shadowColor = defaultColor?.cgColor
                followButton.setBackgroundImage(defaultColor?.image(), for: .normal)
            }
            
            // TODO: Re-enable follow buttons once we get to the Favorites tab
            /*if let contentId = article.author?.id {
                Auth.auth().currentUser?.isFollowing(contentId, { (following, _) in
                    self.followButton.isHidden = following
                })
            }*/
        }
        
        topicPromotedLabel.isHidden = !(article.promoted.value ?? false)
        sourceImageView.sd_setImage(with: article.sourceLogoURL(),
                                    placeholderImage: defaultPlaceholderColor?.image())
        sourceLabel.text = "\(article.source ?? "") • \(article.createdAt?.timeAgoSinceNow ?? "")"
        
        if article.source == nil || article.sourceLogoURL() == nil,
            let url = URL(string: article.link ?? ""),
            let createdAt = article.createdAt {
            OpenGraph.fetch(url: url) { (results, _) in
                if let results = results {
                    if let source = results[.siteName] {
                        DispatchQueue.main.async {
                            self.sourceLabel.text = "\(source) • \(createdAt.timeAgoSinceNow)"
                        }
                    }
                }
            }
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.path = ""
            if let baseURL = components?.url {
                try? FavIcon.downloadPreferred(baseURL) { (result) in
                    switch result {
                    case .success(let resultImage):
                        self.sourceImageView.image = resultImage
                    case .failure:
                        break
                    }
                }
            }
            
        }
        
        configureArticleContent(article)
        
        if let advertisement = advertisement {
            configureAdvertisementContent(advertisement)
        }
    }
    
    private func configureArticleContent(_ article: KPArticle) {
        let articleTitleParagraphStyle = NSMutableParagraphStyle()
        articleTitleParagraphStyle.lineSpacing = 1.5
        articleTitleParagraphStyle.lineBreakMode = .byTruncatingTail
        let articleDescriptionParagraphStyle = NSMutableParagraphStyle()
        articleDescriptionParagraphStyle.lineSpacing = 1.33
        articleDescriptionParagraphStyle.lineBreakMode = .byTruncatingTail
        
        let articleTitleAttributedText = NSAttributedString(string: article.title ?? "",
                                                            attributes:
            [NSAttributedString.Key.paragraphStyle: articleTitleParagraphStyle])
        let articleDescriptionAttributedText = NSAttributedString(string: article.articleDescription ?? "",
                                                                  attributes:
            [NSAttributedString.Key.paragraphStyle: articleDescriptionParagraphStyle])
        
        articleTitleLabel.attributedText = articleTitleAttributedText
        articleDescriptionLabel.attributedText = articleDescriptionAttributedText
    }
    
    private func configureAdvertisementContent(_ advertisement: KPAdvertisement) {
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

        if let imageURL = advertisement.imageURL() {
            advertisementButton.sd_imageTransition = .fade
            advertisementButton.sd_setBackgroundImage(with: imageURL,
                                                      for: .normal,
                                                      placeholderImage: defaultPlaceholderColor?.image())
        } else {
            advertisementButton.setBackgroundImage(defaultPlaceholderColor?.image(), for: .normal)
        }
    }
}
