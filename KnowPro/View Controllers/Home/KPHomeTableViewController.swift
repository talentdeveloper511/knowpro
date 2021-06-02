//
//  KPHomeTableViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/4/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices
import Firebase

class KPHomeTableViewController: UITableViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var footerAdvertisementImageView: UIImageView!
    
    // MARK: - Controller Properties
    
    private var realm: Realm?
    private var notificationToken: NotificationToken?
    private var feedItems: Results<KPArticle>?
    private var footerAdvertisement: KPAdvertisement?
    private var timeStartedViewing = Date()
    private var selectedAdvertisement: KPAdvertisement?
    private var selectedArticle: KPArticle?
    
    // MARK: - Actions
    
    @objc private func resync() {
        tableView.refreshControl?.beginRefreshing()
        KPContentfulStore.sharedStore.sync {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.configureAdvertisements()
            }
        }
    }
    
    @IBAction private func footerAdvertisementPressed(_ sender: AnyObject) {
        guard let link = footerAdvertisement?.link, let url = URL(string: link) else { return }
        
        selectedAdvertisement = footerAdvertisement
        selectedArticle = nil
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
        
        configureViews()
        configureObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let feedItem = feedItems?[indexPath.row] else {
            return tableView.dequeueReusableCell(withIdentifier: "Article", for: indexPath)
        }
        
        KPImpressionStore.sharedStore.recordImpression(feedItem.id, feedItem.title ?? "", .article)
        
        var advertisement: KPAdvertisement?
        
        if let realm = feedItem.realm,
            indexPath.row % 3 == 0 &&
                indexPath.row != 0 &&
                indexPath.row != (feedItems?.count ?? 0) - 1 {
            advertisement = realm.objects(KPAdvertisement.self)
                .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.banner.rawValue))
                .randomElement()
            
            if let advertisement = advertisement {
                KPImpressionStore.sharedStore.recordImpression(advertisement.id,
                                                               advertisement.advertisementId ?? "",
                                                               .advertisement)
            }
        }
        
        if feedItem.imageURL() != nil {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: advertisement != nil ?
                "PremiumArticleAd" : "PremiumArticle", for: indexPath)
            
            // Configure the cell...
            if let cell = cell as? KPPremiumArticleTableViewCell {
                cell.configure(feedItem, advertisement)
                cell.delegate = self
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: advertisement != nil ?
                "ArticleAd" : "Article", for: indexPath)
            
            // Configure the cell...
            if let cell = cell as? KPArticleTableViewCell {
                cell.configure(feedItem, advertisement)
                cell.delegate = self
            }
            
            return cell
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
        guard let feedItem = feedItems?[indexPath.row], let url = URL(string: feedItem.link ?? "") else { return }
        
        selectedArticle = feedItem
        selectedAdvertisement = nil
        timeStartedViewing = Date()
        let safariViewController = SFSafariViewController(url: url)
    
        safariViewController.preferredBarTintColor = tabBarController?.tabBar.barTintColor
        safariViewController.preferredControlTintColor = tabBarController?.tabBar.unselectedItemTintColor
        
        if let drug = feedItem.drug, let primaryColor = drug.primaryColor {
            let hexColor = UIColor(hex: primaryColor)
            safariViewController.preferredControlTintColor = hexColor
        } else if let company = feedItem.author, let primaryColor = company.primaryColor {
            let hexColor = UIColor(hex: primaryColor)
            safariViewController.preferredControlTintColor = hexColor
        }
        safariViewController.delegate = self

        present(safariViewController, animated: true, completion: nil)
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
            let drug = sender as? KPDrug {
            destination.drug = drug
        } else if let destination = segue.destination as? KPCompanyViewController, let company = sender as? KPCompany {
            destination.company = company
        }
    }
 
    // MARK: - Private Methods
    
    private func configureObservers() {
        do {
            realm = try Realm()
            feedItems = realm?.objects(KPArticle.self)
                .filter(NSPredicate(format: "mainFeed == true"))
                .sorted(by: [SortDescriptor(keyPath: "promoted", ascending: false),
                             SortDescriptor(keyPath: "createdAt", ascending: false)])
            
            notificationToken = feedItems?.observe({ (changes) in
                guard let tableView = self.tableView else { return }
                
                switch changes {
                case .initial:
                    tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    tableView.performBatchUpdates({
                        tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                             with: .automatic)
                        tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                             with: .automatic)
                        tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                             with: .automatic)
                    }, completion: nil)
                case .error(let error):
                    fatalError("\(error)")
                }
            })
            
            configureAdvertisements()

        } catch {
            
        }
    }
    
    private func configureViews() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(resync), for: .valueChanged)
        refreshControl.tintColor = tableView.tintColor
        
        tableView.refreshControl = refreshControl
    }
    
    private func configureAdvertisements() {
        guard let realm = realm else { return }
        
        footerAdvertisement = realm.objects(KPAdvertisement.self)
            .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.bottom.rawValue))
            .randomElement()
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
        
        if let advertisement = footerAdvertisement {
            KPImpressionStore.sharedStore.recordImpression(advertisement.id,
                                                           advertisement.advertisementId ?? "",
                                                           .advertisement)
        }

        if let advertisement = footerAdvertisement, let imageURL = advertisement.imageURL() {
            footerAdvertisementImageView.sd_imageTransition = .fade
            footerAdvertisementImageView.sd_setImage(with: imageURL, placeholderImage: defaultPlaceholderColor?.image())
        } else {
            footerAdvertisementImageView.image = defaultPlaceholderColor?.image()
        }
    }
    
    // MARK: - Deinitializers

    deinit {
        notificationToken?.invalidate()
    }
}

extension KPHomeTableViewController: KPArticleTableViewCellDelegate {
    
    func followingStatusChanged(_ cell: KPArticleTableViewCell) {
        var visiblePaths = tableView.indexPathsForVisibleRows ?? []
        
        if let indexPath = tableView.indexPath(for: cell) {
            visiblePaths.removeAll { (visiblePath) -> Bool in
                return visiblePath == indexPath
            }
        }
        
        tableView.reloadRows(at: visiblePaths, with: .fade)
    }
    
    func sponsorButtonTapped(_ article: KPArticle?) {
        guard let article = article else { return }
        
        if let drug = article.drug {
            performSegue(withIdentifier: "DrugSegue", sender: drug)
        } else if let company = article.author {
            performSegue(withIdentifier: "CompanySegue", sender: company)
        }
    }
    
    func advertisementTapped(_ link: String, _ advertisement: KPAdvertisement?) {
        guard let url = URL(string: link) else { return }
        
        selectedAdvertisement = advertisement
        selectedArticle = nil
        timeStartedViewing = Date()
        let safariViewController = SFSafariViewController(url: url)
        
        safariViewController.preferredBarTintColor = tabBarController?.tabBar.barTintColor
        safariViewController.preferredControlTintColor = tabBarController?.tabBar.unselectedItemTintColor
        safariViewController.delegate = self

        present(safariViewController, animated: true, completion: nil)
    }
}

extension KPHomeTableViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let advertisement = selectedAdvertisement {
            KPImpressionStore.sharedStore.recordView(advertisement.id,
                                                     advertisement.advertisementId ?? "",
                                                     .advertisement,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
        
        if let article = selectedArticle {
            KPImpressionStore.sharedStore.recordView(article.id,
                                                     article.title ?? "",
                                                     .article,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
    }
}
