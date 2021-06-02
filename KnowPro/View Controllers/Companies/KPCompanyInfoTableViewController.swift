//
//  KPCompanyInfoTableViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/27/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import SafariServices
import DTOverlayController
import MessageUI

enum KPCompanyInfoSection {
    case drugs
    case info
    case contactRep
}

class KPCompanyInfoTableViewController: UITableViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet var searchContainer: UIView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet private weak var footerAdvertisementImageView: UIImageView!

    // MARK: - Controller Properties
    
    var company: KPCompany?
    var selectedSection: KPCompanyInfoSection? = .drugs {
        didSet {
            if selectedSection ?? .drugs == .drugs {
                tableView.tableHeaderView = searchContainer
            } else {
                tableView.tableHeaderView = UIView(frame: CGRect.zero)
            }
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
    var searchString = "" {
        didSet {
            if selectedSection ?? .drugs == .drugs {
                tableView.reloadData()
            }
        }
    }
    
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let company = company else { return }
        
        if let secondaryColor = company.secondaryColor {
            let hexColor = UIColor(hex: secondaryColor)
            searchTextField.tintColor = hexColor
        }
        
        configureAdvertisements()
        configureContactItems()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedSection == .info || selectedSection == .drugs { return 2 }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && (selectedSection == .info || selectedSection == .drugs) { return 1 }
        
        guard let company = company else { return 0 }
        
        switch selectedSection ?? .drugs {
        case .drugs:
            return searchString.count > 0 ?
                company.drugs.filter(NSPredicate(format: "name CONTAINS[cd] %@", searchString)).count :
                company.drugs.count
        case .info:
            return 1
        case .contactRep:
            return contactItems.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && (selectedSection == .info || selectedSection == .drugs) {
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
        
        switch selectedSection ?? .drugs {
        case .info:
            return self.tableView(tableView, infoCellForRowAt: indexPath)
        case .drugs:
            return self.tableView(tableView, drugCellForRowAt: indexPath)
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
        if selectedSection == .contactRep {
            
            if let contactController = UIStoryboard(name: "Main", bundle: Bundle.main)
                .instantiateViewController(withIdentifier: "KPContactViewController")
                as? KPContactViewController {
                let contactItem = contactItems[indexPath.row]
                selectedContactItem = contactItem
                contactController.companyTitle = company?.name
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? KPDrugViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let drug = company?.drugs[indexPath.row] {
            destination.drug = drug
        }
    }
 
    // MARK: - Private Methods
    
    private func configureAdvertisements() {
        guard let realm = company?.realm else { return }
        
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
    
    private func configureContactItems() {
        guard let company = company else { return }
        
        contactItems = []
        
        if let requestSamples = company.requestSamplesLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Request Samples", comment: ""),
                                              color: UIColor(named: KPConstants.Color.RequestSamples)!,
                                              image: UIImage(named: "RequestSamplesIcon")!,
                                              link: requestSamples,
                                              startingColor: UIColor(red: 0.94, green: 0.29, blue: 0.29, alpha: 1),
                                              endingColor: UIColor(red: 1, green: 0.38, blue: 0.38, alpha: 1)))
        }
        
        if let requestMsl = company.requestMslLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Request MSL", comment: ""),
                                              color: UIColor(named: KPConstants.Color.RequestMsl)!,
                                              image: UIImage(named: "RequestMslIcon")!,
                                              link: requestMsl,
                                              startingColor: UIColor(red: 1, green: 0.58, blue: 0, alpha: 1),
                                              endingColor: UIColor(red: 0.94, green: 0.38, blue: 0.06, alpha: 1)))
        }
        
        if let requestLiterature = company.requestLiteratureLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Request Literature", comment: ""),
                                              color: UIColor(named: KPConstants.Color.RequestLiterature)!,
                                              image: UIImage(named: "RequestLiteratureIcon")!,
                                              link: requestLiterature,
                                              startingColor: UIColor(red: 1, green: 0.87, blue: 0, alpha: 1),
                                              endingColor: UIColor(red: 0.85, green: 0.51, blue: 0.14, alpha: 1)))
        }
        
        if let requestMarketingMaterials = company.requestMarketingMaterialsLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Request Marketing Materials", comment: ""),
                                              color: UIColor(named: KPConstants.Color.RequestMarketingMaterials)!,
                                              image: UIImage(named: "RequestMarketingMaterialsIcon")!,
                                              link: requestMarketingMaterials,
                                              startingColor: UIColor(red: 0.14, green: 0.85, blue: 0.45, alpha: 1),
                                              endingColor: UIColor(red: 0.14, green: 0.85, blue: 0.57, alpha: 1)))
        }
        
        if let otherRequest = company.contactLink {
            contactItems.append(KPContactItem(title: NSLocalizedString("Company Contact", comment: ""),
                                              color: UIColor(named: KPConstants.Color.OtherRequest)!,
                                              image: UIImage(named: "OtherRequestIcon")!,
                                              link: otherRequest,
                                              startingColor: UIColor(red: 0.14, green: 0.76, blue: 0.85, alpha: 1),
                                              endingColor: UIColor(red: 0.43, green: 0.14, blue: 0.85, alpha: 1)))
        }
    }
}
