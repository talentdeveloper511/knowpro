//
//  KPDrugInfoTableViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/21/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import Lightbox
import SafariServices
import DTOverlayController
import MessageUI

enum KPDrugInfoSection {
    case info
    case dosing
    case indications
    case contraindications
    case precautions
    case moreInfo
    case copayCard
    case preferredPharmacy
    case contactRep
}

protocol UITableScrollViewDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

struct KPContactItem {
    let title: String
    let color: UIColor
    let image: UIImage
    let link: String
    let startingColor: UIColor
    let endingColor: UIColor
}

class KPDrugInfoTableViewController: UITableViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var footerAdvertisementImageView: UIImageView!
    
    // MARK: - Controller Properties
    
    var drug: KPDrug?
    var selectedSection: KPDrugInfoSection? {
        didSet {
            tableView.reloadData()
        }
    }
    weak var tableScrollViewDelegate: UITableScrollViewDelegate?
    private var headerAdvertisement: KPAdvertisement?
    private var footerAdvertisement: KPAdvertisement?
    var contactItems: [KPContactItem] = []
    var selectedContactItem: KPContactItem?
    var timeStartedViewing = Date()
    var selectedAdvertisement: KPAdvertisement?
    
    // MARK: - Actions
    
    @IBAction private func headerAdvertisementPressed(_ sender: AnyObject) {
        guard let link = headerAdvertisement?.link, let url = URL(string: link) else { return }
        
        selectedAdvertisement = headerAdvertisement
        timeStartedViewing = Date()
        let safariViewController = SFSafariViewController(url: url)
        
        safariViewController.preferredBarTintColor = tabBarController?.tabBar.barTintColor
        safariViewController.preferredControlTintColor = tabBarController?.tabBar.unselectedItemTintColor
        safariViewController.delegate = self
        
        present(safariViewController, animated: true, completion: nil)
    }
    
    @IBAction private func footerAdvertisementPressed(_ sender: AnyObject) {
        guard let link = footerAdvertisement?.link, let url = URL(string: link) else { return }
        
        selectedAdvertisement = footerAdvertisement
        timeStartedViewing = Date()
        let safariViewController = SFSafariViewController(url: url)
        
        safariViewController.preferredBarTintColor = tabBarController?.tabBar.barTintColor
        safariViewController.preferredControlTintColor = tabBarController?.tabBar.unselectedItemTintColor
        safariViewController.delegate = self
        
        present(safariViewController, animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureAdvertisements()
        configureContactItems()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedSection == .info { return 2 }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedSection == .info && section == 0 {
            return 1
        }
        
        guard let drug = drug else { return 2 }
        
        switch selectedSection ??
            ((drug.copayCard != nil) ?
                KPDrugInfoSection.copayCard : drug.preferredPharmacies.count > 0 ?
                    KPDrugInfoSection.preferredPharmacy : KPDrugInfoSection.contactRep) {
        case .info:
            return 2
        case .dosing:
            return drug.dosageInformation.count
        case .indications:
            return drug.indications.count
        case .contraindications:
            return drug.contraindications.count
        case .precautions:
            return drug.precautions.count
        case .moreInfo:
            return drug.moreInfo.count
        case .copayCard:
            return 1
        case .preferredPharmacy:
            return drug.preferredPharmacies.count
        case .contactRep:
            return contactItems.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && selectedSection == .info {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerAd", for: indexPath)
            let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

            if let cell = cell as? KPBannerAdTableViewCell, let advertisement = headerAdvertisement {
                
                if let imageURL = advertisement.imageURL() {
                    cell.adButton.sd_setBackgroundImage(with: imageURL,
                                                        for: .normal,
                                                        placeholderImage: defaultPlaceholderColor?.image())
                } else {
                    cell.adButton.setBackgroundImage(defaultPlaceholderColor?.image(), for: .normal)
                }
            } else if let cell = cell as? KPBannerAdTableViewCell {
                cell.adButton.setBackgroundImage(defaultPlaceholderColor?.image(), for: .normal)
            }
            
            return cell
        }
        
        guard let drug = drug else { return self.tableView(tableView, infoCellForRowAt: indexPath) }

        switch selectedSection ??
            ((drug.copayCard != nil) ?
                KPDrugInfoSection.copayCard : drug.preferredPharmacies.count > 0 ?
                    KPDrugInfoSection.preferredPharmacy : KPDrugInfoSection.contactRep) {
        case .info:
            return self.tableView(tableView, infoCellForRowAt: indexPath)
        case .dosing:
            return self.tableView(tableView, dosingCellForRowAt: indexPath)
        case .indications:
            return self.tableView(tableView, indicationCellForRowAt: indexPath)
        case .contraindications:
            return self.tableView(tableView, contraindicationCellForRowAt: indexPath)
        case .precautions:
            return self.tableView(tableView, precautionCellForRowAt: indexPath)
        case .moreInfo:
            return self.tableView(tableView, moreInfoCellForRowAt: indexPath)
        case .copayCard:
            return self.tableView(tableView, copayCellForRowAt: indexPath)
        case .preferredPharmacy:
            return self.tableView(tableView, pharmacyCellForRowAt: indexPath)
        case .contactRep:
            return self.tableView(tableView, contactCellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        for cell in tableView.visibleCells {
            tableView.bringSubviewToFront(cell)
        }
        
        tableView.bringSubviewToFront(cell)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedSection ??
            ((drug?.copayCard ?? nil != nil) ?
                KPDrugInfoSection.copayCard : drug?.preferredPharmacies.count ?? 0 > 0 ?
                    KPDrugInfoSection.preferredPharmacy : KPDrugInfoSection.contactRep) == .copayCard,
            let copayCardLink = drug?.copayCardLink, let url = URL(string: copayCardLink) {
            let safariViewController = SFSafariViewController(url: url)
            
            safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
            self.present(safariViewController, animated: true, completion: nil)
        } else if selectedSection == .contactRep {
            
            if let contactController = UIStoryboard(name: "Main", bundle: Bundle.main)
                .instantiateViewController(withIdentifier: "KPContactViewController")
                as? KPContactViewController {
                let contactItem = contactItems[indexPath.row]
                selectedContactItem = contactItem
                contactController.companyTitle = drug?.producer?.name
                contactController.contactIcon = contactItem.image
                contactController.contactTitle = contactItem.title
                contactController.contactPrimaryColor = contactItem.color
                contactController.contactString = contactItem.link
                contactController.contactStartingColor = contactItem.startingColor
                contactController.contactEndingColor = contactItem.endingColor
                contactController.contactViewControllerDelegate = self
                
                let overlayController = DTOverlayController(viewController: contactController,
                                                            overlayHeight: .dynamic(0.5),
                                                            dismissableProgress: 0.4)
                overlayController.overlayViewCornerRadius = 24
                overlayController.handleVerticalSpace = -12
                
                tabBarController?.present(overlayController, animated: true, completion: nil)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableScrollViewDelegate?.scrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tableScrollViewDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? KPCompanyViewController, let company = drug?.producer {
            destination.company = company
        }
    }
    
    // MARK: - Private Methods
    
    private func configureContactItems() {
        guard let drug = drug else { return }
        
        contactItems = []
        
        if let requestMarketingMaterials = drug.requestMarketingMaterialsLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Documents & Forms", comment: ""),
                                              color: UIColor(named: KPConstants.Color.RequestMarketingMaterials)!,
                                              image: UIImage(named: "RequestMarketingMaterialsIcon")!,
                                              link: requestMarketingMaterials,
                                              startingColor: UIColor(red: 0.14, green: 0.85, blue: 0.45, alpha: 1),
                                              endingColor: UIColor(red: 0.14, green: 0.85, blue: 0.57, alpha: 1)))
        }
        
        if let requestLiterature = drug.requestLiteratureLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Contact Rep", comment: ""),
                                              color: UIColor(named: KPConstants.Color.RequestLiterature)!,
                                              image: UIImage(named: "RequestLiteratureIcon")!,
                                              link: requestLiterature,
                                              startingColor: UIColor(red: 1, green: 0.87, blue: 0, alpha: 1),
                                              endingColor: UIColor(red: 0.85, green: 0.51, blue: 0.14, alpha: 1)))
        }
        
        if let requestSamples = drug.requestSamplesLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Request Samples", comment: ""),
                                              color: UIColor(named: KPConstants.Color.RequestSamples)!,
                                              image: UIImage(named: "RequestSamplesIcon")!,
                                              link: requestSamples,
                                              startingColor: UIColor(red: 0.94, green: 0.29, blue: 0.29, alpha: 1),
                                              endingColor: UIColor(red: 1, green: 0.38, blue: 0.38, alpha: 1)))
        }
        
        if let requestMsl = drug.requestMslLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Request MSL", comment: ""),
                                              color: UIColor(named: KPConstants.Color.RequestMsl)!,
                                              image: UIImage(named: "RequestMslIcon")!,
                                              link: requestMsl,
                                              startingColor: UIColor(red: 1, green: 0.58, blue: 0, alpha: 1),
                                              endingColor: UIColor(red: 0.94, green: 0.38, blue: 0.06, alpha: 1)))
        }
        
        if let otherRequest = drug.generalContactLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Other Requests", comment: ""),
                                              color: UIColor(named: KPConstants.Color.OtherRequest)!,
                                              image: UIImage(named: "OtherRequestIcon")!,
                                              link: otherRequest,
                                              startingColor: UIColor(red: 0.14, green: 0.76, blue: 0.85, alpha: 1),
                                              endingColor: UIColor(red: 0.43, green: 0.14, blue: 0.85, alpha: 1)))
        }
    }
    
    private func configureAdvertisements() {
        guard let realm = drug?.realm else { return }
        
        footerAdvertisement = realm.objects(KPAdvertisement.self)
            .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.bottom.rawValue))
            .randomElement()
        headerAdvertisement = realm.objects(KPAdvertisement.self)
            .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.top.rawValue))
            .randomElement()
        
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        if let advertisement = footerAdvertisement, let imageURL = advertisement.imageURL() {
            footerAdvertisementImageView.sd_imageTransition = .fade
            footerAdvertisementImageView.sd_setImage(with: imageURL, placeholderImage: defaultPlaceholderColor?.image())
        } else {
            footerAdvertisementImageView.image = defaultPlaceholderColor?.image()
        }
    }
}
