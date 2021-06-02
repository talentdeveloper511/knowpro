//
//  KPDrugsTableViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/20/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices

class KPDrugsTableViewController: UITableViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var headerAdvertisementButton: UIButton!
    @IBOutlet private weak var footerAdvertisementImageView: UIImageView!

    // MARK: - Controller Properties
    
    private var realm: Realm?
    private var notificationToken: NotificationToken?
    private var drugs: Results<KPDrug>?
    private var headerAdvertisement: KPAdvertisement?
    private var footerAdvertisement: KPAdvertisement?
    private var timeStartedViewing = Date()
    private var selectedAdvertisement: KPAdvertisement?
    
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
        
        selectedAdvertisement = headerAdvertisement
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
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drugs?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let drug = drugs?[indexPath.row] else {
            return tableView.dequeueReusableCell(withIdentifier: "BannerAd", for: indexPath)
        }
        
        KPImpressionStore.sharedStore.recordImpression(drug.id, drug.name ?? "", .drug)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrugCell", for: indexPath)
        
        // Configure the cell...
        if let cell = cell as? KPDrugTableViewCell {
            cell.configure(drug)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        for cell in tableView.visibleCells {
            tableView.bringSubviewToFront(cell)
        }
        
        tableView.bringSubviewToFront(cell)
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
            let indexPath = tableView.indexPath(for: cell), let drugs = drugs {
            destination.drug = drugs[indexPath.row]
        }
    }
    
    // MARK: - Private Methods

    private func configureObservers() {
        do {
            realm = try Realm()
            drugs = realm?.objects(KPDrug.self).sorted(byKeyPath: "name")
            
            notificationToken = drugs?.observe({ (changes) in
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
    
    private func configureAdvertisements() {
        guard let realm = realm else { return }
        
        footerAdvertisement = realm.objects(KPAdvertisement.self)
            .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.bottom.rawValue))
            .randomElement()
        headerAdvertisement = realm.objects(KPAdvertisement.self)
            .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.top.rawValue))
            .randomElement()
        
        let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

        if let advertisement = headerAdvertisement, let imageURL = advertisement.imageURL() {
            headerAdvertisementButton.sd_imageTransition = .fade
            headerAdvertisementButton.sd_setBackgroundImage(with: imageURL,
                                                            for: .normal,
                                                            placeholderImage: defaultPlaceholderColor?.image())
            
            KPImpressionStore.sharedStore.recordImpression(advertisement.id,
                                                           advertisement.advertisementId ?? "",
                                                           .advertisement)

        } else {
            headerAdvertisementButton.setBackgroundImage(defaultPlaceholderColor?.image(), for: .normal)
        }
        
        if let advertisement = footerAdvertisement, let imageURL = advertisement.imageURL() {
            footerAdvertisementImageView.sd_imageTransition = .fade
            footerAdvertisementImageView.sd_setImage(with: imageURL, placeholderImage: defaultPlaceholderColor?.image())
            
            KPImpressionStore.sharedStore.recordImpression(advertisement.id,
                                                           advertisement.advertisementId ?? "",
                                                           .advertisement)

        } else {
            footerAdvertisementImageView.image = defaultPlaceholderColor?.image()
        }
    }
    
    private func configureViews() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(resync), for: .valueChanged)
        refreshControl.tintColor = tableView.tintColor
        
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Deinitializers
    
    deinit {
        notificationToken?.invalidate()
    }
}

extension KPDrugsTableViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let advertisement = selectedAdvertisement {
            KPImpressionStore.sharedStore.recordView(advertisement.id,
                                                     advertisement.advertisementId ?? "",
                                                     .advertisement,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
    }
}
