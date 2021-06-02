//
//  KPCompanyViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/26/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import MXSegmentedControl
import Firebase

class KPCompanyViewController: UIViewController {

    // MARK: - Interface Properies
    
    @IBOutlet private weak var segmentControl: MXSegmentedControl!
    @IBOutlet private weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var companyImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var companyImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var companyImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var companyImageInternalHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var companyImageInternalWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var premiumContainerView: UIView!
    @IBOutlet private weak var headerBackgroundView: UIView!
    @IBOutlet private weak var galleryOverlayView: KPGradientView!
    @IBOutlet weak var galleryPageControl: UIPageControl!
    @IBOutlet private weak var companyImageView: UIImageView!
    @IBOutlet private weak var companyBackgroundShadowView: UIView!
    @IBOutlet private weak var followButton: UIButton!
    @IBOutlet private weak var unfollowButton: UIButton!
    
    // MARK: - Controller Properties
    
    private let minHeightConstant: CGFloat = 61
    private let maxHeightConstant: CGFloat = 286
    private var lastOffset: CGFloat = 0
    private var infoTableViewController: KPCompanyInfoTableViewController?
    private var galleryCollectionViewController: KPGalleryCollectionViewController?
    private var segmentTitles: [String] = []
    private var segmentSections: [KPCompanyInfoSection] = []
    var company: KPCompany?
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
        
        if let contentId = company?.id {
            Auth.auth().currentUser?.follow(contentId, { (_, err) in
                if err != nil {
                    self.followButton.isHidden = false
                }
            })
        }
        
    }
    
    @IBAction private func unfollowButtonPressed(_ sender: AnyObject) {
        let unfollowActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let unfollowString = NSLocalizedString("Unfollow", comment: "") + " \(company?.name ?? "")"
        unfollowActionSheet.addAction(UIAlertAction(title: unfollowString, style: .destructive, handler: { (_) in
            self.followButton.isHidden = false
            
            if let contentId = self.company?.id {
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
        
        for child in children where child is KPCompanyInfoTableViewController {
            infoTableViewController = child as? KPCompanyInfoTableViewController
            infoTableViewController?.company = company
            infoTableViewController?.tableScrollViewDelegate = self
        }
        
        for child in children where child is KPGalleryCollectionViewController {
            galleryCollectionViewController = child as? KPGalleryCollectionViewController
            galleryCollectionViewController?.galleryImages = company?.galleryMedia
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
        
        if let company = company {
            KPImpressionStore.sharedStore.recordView(company.id,
                                                     company.name ?? "",
                                                     .company,
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
        
        companyBackgroundShadowView.layer.shadowColor = defaultColor?.cgColor
        companyBackgroundShadowView.layer.shadowOffset = CGSize(width: 0, height: 8)
        companyBackgroundShadowView.layer.shadowRadius = 16
        companyBackgroundShadowView.layer.shadowOpacity = 0.1
        
        companyImageView.sd_imageTransition = .fade
        companyImageView.image = defaultPlaceholderColor?.image()
        
        followButton.setBackgroundImage(defaultColor?.image(), for: .normal)
        followButton.titleLabel?.letterSpace = 2
        
        // TODO: Re-enable follow buttons once we get to the Favorites tab
        followButton.isHidden = true
        unfollowButton.isHidden = true
        
        if company?.galleryMedia.count == 0 || company?.premium.value ?? false == false {
            headerBottomConstraint.constant = minHeightConstant
            companyImageHeightConstraint.constant = 0
            companyImageLeadingConstraint.constant = 60
            companyImageBottomConstraint.constant = 6.5
            premiumContainerView.alpha = 0
        }
        
        if let company = company {
            configure(company)
        }
        
        view.layoutIfNeeded()
    }
    
    private func configure(_ company: KPCompany) {
        
        let defaultColor = UIColor(named: KPConstants.Color.LogoRed)
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        if let secondaryColor = company.secondaryColor {
            let hexColor = UIColor(hexFromString: secondaryColor)
            headerBackgroundView.backgroundColor = hexColor
            companyBackgroundShadowView.layer.shadowColor = hexColor.cgColor
        } else {
            companyBackgroundShadowView.layer.shadowColor = defaultColor?.cgColor
            headerBackgroundView.backgroundColor = defaultColor
        }
        
        if let primaryColor = company.primaryColor {
            let hexColor = UIColor(hexFromString: primaryColor)
            galleryOverlayView.gradientColor = hexColor
            
            followButton.setBackgroundImage(hexColor.image(), for: .normal)
            segmentControl.selectedTextColor = hexColor
            segmentControl.indicatorColor = hexColor
            
        }
        
        companyImageView.sd_setImage(with: company.smallLogoURL(),
                                  placeholderImage: defaultPlaceholderColor?.image())
        
        galleryPageControl.numberOfPages = company.galleryMedia.count
        
        // TODO: Re-enable follow buttons once we get to the Favorites tab
        /*Auth.auth().currentUser?.isFollowing(company.id, { (following, _) in
            self.followButton.isHidden = following
        })*/
        
        configureData(company)
    }
    
    private func configureData(_ company: KPCompany) {
        if segmentControl.count == 0 {
            segmentTitles.append(NSLocalizedString("Drugs", comment: ""))
            segmentSections.append(.drugs)
            
            segmentTitles.append(NSLocalizedString("News & Info", comment: ""))
            segmentSections.append(.info)
            
            segmentTitles.append(NSLocalizedString("Contact", comment: ""))
            segmentSections.append(.contactRep)
            
            for segmentTitle in segmentTitles {
                segmentControl.append(title: segmentTitle)
            }
        }
    }

}

extension KPCompanyViewController: UITableScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if company?.galleryMedia.count == 0 || company?.premium.value ?? false == false {
            return
        }
        
        if scrollView.isTracking {
            let offset = scrollView.contentOffset.y
            let newHeaderPos = headerBottomConstraint.constant - offset
            
            if newHeaderPos > maxHeightConstant {
                headerBottomConstraint.constant = maxHeightConstant
                companyImageHeightConstraint.constant = -44
                companyImageLeadingConstraint.constant = 16
                companyImageBottomConstraint.constant = 16
                companyImageInternalWidthConstraint.constant = -16.0
                companyImageInternalHeightConstraint.constant = -16.0
                premiumContainerView.alpha = 1
            } else if newHeaderPos < minHeightConstant {
                headerBottomConstraint.constant = minHeightConstant
                companyImageHeightConstraint.constant = 0
                companyImageLeadingConstraint.constant = 60
                companyImageBottomConstraint.constant = 6.5
                companyImageInternalWidthConstraint.constant = 0
                companyImageInternalHeightConstraint.constant = 0
                premiumContainerView.alpha = 0
            } else {
                let completionPercentage = (newHeaderPos - minHeightConstant) / (maxHeightConstant - minHeightConstant)
                companyImageLeadingConstraint.constant = 60 - 44 * completionPercentage
                companyImageHeightConstraint.constant = -44 * completionPercentage
                companyImageBottomConstraint.constant = 6.5 + 9.5 * completionPercentage
                companyImageInternalWidthConstraint.constant = -16.0 * completionPercentage
                companyImageInternalHeightConstraint.constant = -16.0 * completionPercentage
                headerBottomConstraint.constant = newHeaderPos
                premiumContainerView.alpha = completionPercentage
                
                scrollView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: false)
            }
            
            lastOffset = offset
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if company?.galleryMedia.count == 0 || company?.premium.value ?? false == false {
            return
        }
        
        let completionPercentage = (headerBottomConstraint.constant - minHeightConstant) /
            (maxHeightConstant - minHeightConstant)
        
        if completionPercentage > 0.5 {
            headerBottomConstraint.constant = maxHeightConstant
            companyImageHeightConstraint.constant = -44
            companyImageLeadingConstraint.constant = 16
            companyImageBottomConstraint.constant = 16
            companyImageInternalWidthConstraint.constant = -16.0
            companyImageInternalHeightConstraint.constant = -16.0
            premiumContainerView.alpha = 1
        } else {
            headerBottomConstraint.constant = minHeightConstant
            companyImageHeightConstraint.constant = 0
            companyImageLeadingConstraint.constant = 60
            companyImageBottomConstraint.constant = 6.5
            companyImageInternalWidthConstraint.constant = 0
            companyImageInternalHeightConstraint.constant = 0
            premiumContainerView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
