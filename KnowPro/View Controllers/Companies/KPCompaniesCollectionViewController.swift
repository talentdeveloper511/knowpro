//
//  KPCompaniesCollectionViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/26/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices
import SDWebImage

private let reuseIdentifier = "Cell"

class KPCompaniesCollectionViewController: UICollectionViewController {
    
    // MARK: - Controller Properties
    
    private var realm: Realm?
    private var notificationToken: NotificationToken?
    private var companies: Results<KPCompany>?
    private var headerAdvertisement: KPAdvertisement?
    private var footerAdvertisement: KPAdvertisement?
    private var timeStartedViewing = Date()
    private var selectedAdvertisement: KPAdvertisement?
    
    // MARK: - Actions
    
    @objc private func resync() {
        collectionView.refreshControl?.beginRefreshing()
        KPContentfulStore.sharedStore.sync {
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
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
        
        selectedAdvertisement = footerAdvertisement
        timeStartedViewing = Date()
        let safariViewController = SFSafariViewController(url: url)
        
        safariViewController.preferredBarTintColor = tabBarController?.tabBar.barTintColor
        safariViewController.preferredControlTintColor = tabBarController?.tabBar.unselectedItemTintColor
        safariViewController.delegate = self
        
        present(safariViewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width:
            collectionView.bounds.width / 2.0 - 15.0,
                                                                                                height: 104.0)
        collectionView.contentInsetAdjustmentBehavior = .never
        
        configureViews()
        configureObservers()
        configureAdvertisements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let itemSize = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
        let expectedItemSize = CGSize(width: collectionView.bounds.width / 2.0 - 15.0, height: 104.0)
        if itemSize != expectedItemSize {
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = expectedItemSize
            collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? KPCompanyViewController,
            let cell = sender as? UICollectionViewCell,
            let indexPath = collectionView.indexPath(for: cell),
            let companies = companies {
            destination.company = companies[indexPath.row]
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return companies?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let company = companies?[indexPath.item] else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        }
        
        KPImpressionStore.sharedStore.recordImpression(company.id, company.name ?? "", .company)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCell", for: indexPath)
    
        // Configure the cell
        if let cell = cell as? KPCompanyCollectionViewCell {
            cell.configure(company)
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "HeaderView",
                                                                         for: indexPath)
            let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

            if let advertisement = headerAdvertisement, let header = header as? KPHeaderCollectionReusableView {
                
                KPImpressionStore.sharedStore.recordImpression(advertisement.id,
                                                               advertisement.advertisementId ?? "",
                                                               .advertisement)
                
                if let imageURL = advertisement.imageURL() {
                    header.advertisementButton.sd_imageTransition = .fade
                    header.advertisementButton.sd_setBackgroundImage(with: imageURL,
                                                                     for: .normal,
                                                                     placeholderImage: defaultPlaceholderColor?.image())
                } else {
                    header.advertisementButton.setBackgroundImage(defaultPlaceholderColor?.image(), for: .normal)
                }
                
            } else if let header = header as? KPHeaderCollectionReusableView {
                header.advertisementButton.setBackgroundImage(defaultPlaceholderColor?.image(), for: .normal)
            }
            
            return header
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "FooterView",
                                                                         for: indexPath)
            
            let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)

            if let advertisement = footerAdvertisement, let footer = footer as? KPFooterCollectionReusableView {
                let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
                
                KPImpressionStore.sharedStore.recordImpression(advertisement.id,
                                                               advertisement.advertisementId ?? "",
                                                               .advertisement)
                
                if let imageURL = advertisement.imageURL() {
                    footer.advertisementImageView.sd_imageTransition = .fade
                    footer.advertisementImageView.sd_setImage(with: imageURL,
                                                              placeholderImage: defaultPlaceholderColor?.image())
                } else {
                    footer.advertisementImageView.image = defaultPlaceholderColor?.image()
                }
                
            } else if let footer = footer as? KPFooterCollectionReusableView {
                footer.advertisementImageView.image = defaultPlaceholderColor?.image()
            }
            return footer
        default:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "FooterView",
                                                                         for: indexPath)
            return footer
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: - Private Methods
    
    private func configureObservers() {
        do {
            realm = try Realm()
            companies = realm?.objects(KPCompany.self).sorted(byKeyPath: "name")
            
            notificationToken = companies?.observe({ (changes) in
                guard let collectionView = self.collectionView else { return }
                
                switch changes {
                case .initial:
                    collectionView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    collectionView.performBatchUpdates({
                        collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0) }))
                        collectionView.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0)}))
                        collectionView.reloadItems(at: modifications.map({ IndexPath(row: $0, section: 0) }))
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
        refreshControl.tintColor = collectionView.tintColor
        
        collectionView.refreshControl = refreshControl
    }
    
    private func configureAdvertisements() {
        guard let realm = realm else { return }
        
        footerAdvertisement = realm.objects(KPAdvertisement.self)
            .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.bottom.rawValue))
            .randomElement()
        headerAdvertisement = realm.objects(KPAdvertisement.self)
            .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.top.rawValue))
            .randomElement()
    }
    
    // MARK: - Deinitializers
    
    deinit {
        notificationToken?.invalidate()
    }

}

extension KPCompaniesCollectionViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let advertisement = selectedAdvertisement {
            KPImpressionStore.sharedStore.recordView(advertisement.id,
                                                     advertisement.advertisementId ?? "",
                                                     .advertisement,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
    }
}
