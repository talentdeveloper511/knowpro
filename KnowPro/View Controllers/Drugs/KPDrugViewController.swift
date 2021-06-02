//
//  KPDrugViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/20/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import MXSegmentedControl
import Firebase

class KPDrugViewController: UIViewController {
    
    // MARK: - Interface Properies
    
    @IBOutlet private weak var segmentControl: MXSegmentedControl!
    @IBOutlet private weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var drugImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var drugImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var drugImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var drugImageInternalHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var drugImageInternalWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var premiumContainerView: UIView!
    @IBOutlet private weak var headerBackgroundView: UIView!
    @IBOutlet private weak var galleryOverlayView: KPGradientView!
    @IBOutlet weak var galleryPageControl: UIPageControl!
    @IBOutlet private weak var drugImageView: UIImageView!
    @IBOutlet private weak var drugBackgroundShadowView: UIView!
    @IBOutlet private weak var followButton: UIButton!
    @IBOutlet private weak var unfollowButton: UIButton!
    
    // MARK: - Controller Properties
    
    private let minHeightConstant: CGFloat = 61
    private let maxHeightConstant: CGFloat = 286
    private var lastOffset: CGFloat = 0
    private var infoTableViewController: KPDrugInfoTableViewController?
    private var galleryCollectionViewController: KPGalleryCollectionViewController?
    private var segmentTitles: [String] = []
    private var segmentSections: [KPDrugInfoSection] = []
    var drug: KPDrug?
    private var timeStartedViewing = Date()
    
    // MARK: - Actions
    
    @IBAction private func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func sectionChanged(_ sender: MXSegmentedControl) {
        infoTableViewController?.selectedSection = segmentSections[sender.selectedIndex]
    }
    
    @IBAction private func followButtonPressed(_ sender: AnyObject) {
        followButton.isHidden = true
        
        if let contentId = drug?.id {
            Auth.auth().currentUser?.follow(contentId, { (_, err) in
                if err != nil {
                    self.followButton.isHidden = false
                }
            })
        }
        
    }
    
    @IBAction private func unfollowButtonPressed(_ sender: AnyObject) {
        let unfollowActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let unfollowString = NSLocalizedString("Unfollow", comment: "") + " \(drug?.name ?? "")"
        unfollowActionSheet.addAction(UIAlertAction(title: unfollowString, style: .destructive, handler: { (_) in
            self.followButton.isHidden = false
            
            if let contentId = self.drug?.id {
                Auth.auth().currentUser?.unfollow(contentId, { (_, err) in
                    if err != nil {
                        self.followButton.isHidden = true
                    }
                })
            }
        }))
        unfollowActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                                    style: .cancel,
                                                    handler: nil))
        
        present(unfollowActionSheet, animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for child in children where child is KPDrugInfoTableViewController {
            infoTableViewController = child as? KPDrugInfoTableViewController
            infoTableViewController?.drug = drug
            infoTableViewController?.tableScrollViewDelegate = self
        }
        
        for child in children where child is KPGalleryCollectionViewController {
            galleryCollectionViewController = child as? KPGalleryCollectionViewController
            galleryCollectionViewController?.galleryImages = drug?.galleryMedia
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureViews()
        timeStartedViewing = Date()
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let drug = drug {
            KPImpressionStore.sharedStore.recordView(drug.id,
                                                     drug.name ?? "",
                                                     .drug,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Private Methods
    
    private func configureViews() {
        
        segmentControl.font = UIFont.boldSystemFont(ofSize: 13)
        
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        drugBackgroundShadowView.layer.shadowColor = defaultColor?.cgColor
        drugBackgroundShadowView.layer.shadowOffset = CGSize(width: 0, height: 8)
        drugBackgroundShadowView.layer.shadowRadius = 16
        drugBackgroundShadowView.layer.shadowOpacity = 0.1
        
        drugImageView.sd_imageTransition = .fade
        drugImageView.image = defaultPlaceholderColor?.image()
        
        followButton.setBackgroundImage(defaultColor?.image(), for: .normal)
        followButton.titleLabel?.letterSpace = 2
        
        // TODO: Re-enable follow buttons once we get to the Favorites tab
        followButton.isHidden = true
        unfollowButton.isHidden = true
        
        if drug?.galleryMedia.count == 0 || drug?.producer?.premium.value ?? false == false {
            headerBottomConstraint.constant = minHeightConstant
            drugImageHeightConstraint.constant = 0
            drugImageLeadingConstraint.constant = 60
            drugImageBottomConstraint.constant = 6.5
            premiumContainerView.alpha = 0
        }

        if let drug = drug {
            configure(drug)
        }
        
        view.layoutIfNeeded()
    }
    
    private func configure(_ drug: KPDrug) {
        
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        if let secondaryColor = drug.secondaryColor {
            let hexColor = UIColor(hexFromString: secondaryColor)
            headerBackgroundView.backgroundColor = hexColor
            drugBackgroundShadowView.layer.shadowColor = hexColor.cgColor
        } else {
            drugBackgroundShadowView.layer.shadowColor = defaultColor?.cgColor
            headerBackgroundView.backgroundColor = defaultColor
        }
        
        for sublayer in galleryOverlayView.layer.sublayers ?? [] {
            sublayer.removeFromSuperlayer()
        }
        if let primaryColor = drug.primaryColor {
            let hexColor = UIColor(hexFromString: primaryColor)
            galleryOverlayView.gradientColor = hexColor
            
            followButton.setBackgroundImage(hexColor.image(), for: .normal)
            segmentControl.selectedTextColor = hexColor
            segmentControl.indicatorColor = hexColor

        }
        
        drugImageView.sd_setImage(with: drug.smallLogoURL(),
                                  placeholderImage: defaultPlaceholderColor?.image())
        
        galleryPageControl.numberOfPages = drug.galleryMedia.count
        
        // TODO: Re-enable follow buttons once we get to the Favorites tab
        /*Auth.auth().currentUser?.isFollowing(drug.id, { (following, _) in
            self.followButton.isHidden = following
        })*/
        
        configureData(drug)
    }
    
    private func configureData(_ drug: KPDrug) {
        if segmentControl.count == 0 {
            
            if drug.copayCard != nil {
                segmentTitles.append(NSLocalizedString("Copay Card", comment: ""))
                segmentSections.append(.copayCard)
            }
            
            if drug.preferredPharmacies.count > 0 {
                segmentTitles.append(NSLocalizedString("Preferred Pharmacy", comment: ""))
                segmentSections.append(.preferredPharmacy)
            }
            
            segmentTitles.append(NSLocalizedString("Resources", comment: ""))
            segmentSections.append(.contactRep)
            
            segmentTitles.append(NSLocalizedString("News & Info", comment: ""))
            segmentSections.append(.info)
            
            if drug.dosageInformation.count > 0 {
                segmentTitles.append(NSLocalizedString("Dosing", comment: ""))
                segmentSections.append(.dosing)
            }
            
            if drug.indications.count > 0 {
                segmentTitles.append(NSLocalizedString("Indications", comment: ""))
                segmentSections.append(.indications)
            }
            
            if drug.contraindications.count > 0 {
                segmentTitles.append(NSLocalizedString("Contraindications", comment: ""))
                segmentSections.append(.contraindications)
            }
            
            if drug.precautions.count > 0 {
                segmentTitles.append(NSLocalizedString("Precautions", comment: ""))
                segmentSections.append(.precautions)
            }
            
            if drug.moreInfo.count > 0 {
                segmentTitles.append(NSLocalizedString("More Info", comment: ""))
                segmentSections.append(.moreInfo)
            }
            
            for segmentTitle in segmentTitles {
                segmentControl.append(title: segmentTitle)
            }
        }
    }

}

extension KPDrugViewController: UITableScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if drug?.galleryMedia.count == 0 || drug?.producer?.premium.value ?? false == false {
            return
        }
        
        if scrollView.isTracking {
            let offset = scrollView.contentOffset.y
            let newHeaderPos = headerBottomConstraint.constant - offset
            
            if newHeaderPos > maxHeightConstant {
                headerBottomConstraint.constant = maxHeightConstant
                drugImageHeightConstraint.constant = -44
                drugImageLeadingConstraint.constant = 16
                drugImageBottomConstraint.constant = 16
                drugImageInternalWidthConstraint.constant = -16
                drugImageInternalHeightConstraint.constant = -16
                premiumContainerView.alpha = 1
            } else if newHeaderPos < minHeightConstant {
                headerBottomConstraint.constant = minHeightConstant
                drugImageHeightConstraint.constant = 0
                drugImageLeadingConstraint.constant = 60
                drugImageBottomConstraint.constant = 6.5
                drugImageInternalWidthConstraint.constant = 0
                drugImageInternalHeightConstraint.constant = 0
                premiumContainerView.alpha = 0
            } else {
                let completionPercentage = (newHeaderPos - minHeightConstant) / (maxHeightConstant - minHeightConstant)
                drugImageLeadingConstraint.constant = 60 - 44 * completionPercentage
                drugImageHeightConstraint.constant = -44 * completionPercentage
                drugImageBottomConstraint.constant = 6.5 + 9.5 * completionPercentage
                drugImageInternalWidthConstraint.constant = -16.0 * completionPercentage
                drugImageInternalHeightConstraint.constant = -16.0 * completionPercentage
                headerBottomConstraint.constant = newHeaderPos
                premiumContainerView.alpha = completionPercentage
                
                scrollView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: false)
            }
            
            lastOffset = offset
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if drug?.galleryMedia.count == 0 || drug?.producer?.premium.value ?? false == false {
            return
        }
        
        let completionPercentage = (headerBottomConstraint.constant - minHeightConstant) /
            (maxHeightConstant - minHeightConstant)

        if completionPercentage > 0.5 {
            headerBottomConstraint.constant = maxHeightConstant
            drugImageHeightConstraint.constant = -44
            drugImageLeadingConstraint.constant = 16
            drugImageBottomConstraint.constant = 16
            drugImageInternalWidthConstraint.constant = -16
            drugImageInternalHeightConstraint.constant = -16
            premiumContainerView.alpha = 1
        } else {
            headerBottomConstraint.constant = minHeightConstant
            drugImageHeightConstraint.constant = 0
            drugImageLeadingConstraint.constant = 60
            drugImageBottomConstraint.constant = 6.5
            drugImageInternalWidthConstraint.constant = 0
            drugImageInternalHeightConstraint.constant = 0
            premiumContainerView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
