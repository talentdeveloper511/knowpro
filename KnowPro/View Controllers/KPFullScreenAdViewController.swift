//
//  KPFullScreenAdViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/8/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import SRCountdownTimer
import RealmSwift
import SafariServices

class KPFullScreenAdViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private var adImageView: UIImageView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var countdownTimer: SRCountdownTimer!
    
    // MARK: - Controller Properties
    
    private var advertisement: KPAdvertisement?
    private var timeStartedViewing = Date()
    
    // MARK: - Actions
    
    @IBAction private func closeButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func advertisementTapped(_ sender: AnyObject) {
        guard let link = advertisement?.link, let url = URL(string: link) else { return }
        
        timeStartedViewing = Date()
        let safariViewController = SFSafariViewController(url: url)
        
        safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
        safariViewController.delegate = self
        
        present(safariViewController, animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countdownTimer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureAdvertisement()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Private Methods
    
    private func configureAdvertisement() {
        do {
            let realm = try Realm()
            if let advertisement = realm.objects(KPAdvertisement.self)
                .filter(NSPredicate(format: "adType == %@", KPAdvertisementType.full.rawValue)).randomElement(),
                let imageURL = advertisement.imageURL() {
                
                KPImpressionStore.sharedStore.recordImpression(advertisement.id,
                                                               advertisement.advertisementId ?? "",
                                                               .advertisement)

                self.advertisement = advertisement
                adImageView.sd_setImage(with: imageURL,
                                        placeholderImage: view.backgroundColor?.image()) { (_, _, _, _) in
                    DispatchQueue.main.async {
                        self.countdownTimer.start(beginingValue: 4)
                    }
                }
            } else {
                timerDidEnd()
            }
            
        } catch {
            timerDidEnd()
        }
    }
}

extension KPFullScreenAdViewController: SRCountdownTimerDelegate {
    
    func timerDidEnd() {
        closeButton.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            self.closeButton.alpha = 1
            self.countdownTimer.alpha = 0
        }
    }
}

extension KPFullScreenAdViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let advertisement = advertisement {
            KPImpressionStore.sharedStore.recordView(advertisement.id,
                                                     advertisement.advertisementId ?? "",
                                                     .advertisement,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
    }
}
