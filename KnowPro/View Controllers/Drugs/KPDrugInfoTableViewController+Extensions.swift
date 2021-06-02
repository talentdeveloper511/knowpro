//
//  KPDrugInfoTableViewController+Extensions.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/16/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation
import RealmSwift
import SafariServices
import MessageUI
import Atributika

extension KPDrugInfoTableViewController {
    func tableView(_ tableView: UITableView, infoCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            if let cell = cell as? KPInfoTableViewCell, let drug = drug {
                cell.titleLabel.text = drug.name
                
                let descriptionParagraphStyle = NSMutableParagraphStyle()
                descriptionParagraphStyle.lineSpacing = 1.5
                descriptionParagraphStyle.lineBreakMode = .byWordWrapping
                
                cell.descriptionLabel.numberOfLines = 0
                let link = Style
                    .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .normal)
                    .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .highlighted)
                let all = Style.font(.systemFont(ofSize: 15))
                    .foregroundColor(UIColor(named: KPConstants.Color.GlobalBlack)!)
                    .paragraphStyle(descriptionParagraphStyle)
                
                cell.descriptionLabel.onClick = { label, detection in
                    switch detection.type {
                    case .link(let url):
                        var urlToOpen = url
                        
                        if urlToOpen.scheme == nil {
                            urlToOpen = URL(string: "https://".appending(urlToOpen.absoluteString)) ?? url
                        }
                        
                        if ["http", "https"].contains(urlToOpen.scheme?.lowercased() ?? "") {
                            let safariViewController = SFSafariViewController(url: urlToOpen)
                            
                            safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
                            self.present(safariViewController, animated: true, completion: nil)
                        }
                    default:
                        break
                    }
                }
                cell.descriptionLabel.attributedText = (drug.info ?? "").styleAll(all).styleLinks(link)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProducerCell", for: indexPath)
            if let cell = cell as? KPProducerTableViewCell, let drug = drug {
                cell.configure(drug)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            if let cell = cell as? KPInfoTableViewCell {
                cell.titleLabel.text = nil
                cell.descriptionLabel.attributedText = nil
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, dosingCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        
        if let cell = cell as? KPInfoTableViewCell, let drug = drug {
            let dosingInfo = drug.dosageInformation[indexPath.row]
            
            cell.titleLabel.text = dosingInfo.title
            
            let descriptionParagraphStyle = NSMutableParagraphStyle()
            descriptionParagraphStyle.lineSpacing = 1.5
            descriptionParagraphStyle.lineBreakMode = .byWordWrapping
            
            cell.descriptionLabel.numberOfLines = 0
            let link = Style
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .normal)
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .highlighted)
            let all = Style.font(.systemFont(ofSize: 15))
                .foregroundColor(UIColor(named: KPConstants.Color.GlobalBlack)!)
                .paragraphStyle(descriptionParagraphStyle)
            
            cell.descriptionLabel.onClick = { label, detection in
                switch detection.type {
                case .link(let url):
                    var urlToOpen = url
                    
                    if urlToOpen.scheme == nil {
                        urlToOpen = URL(string: "https://".appending(urlToOpen.absoluteString)) ?? url
                    }
                    
                    if ["http", "https"].contains(urlToOpen.scheme?.lowercased() ?? "") {
                        let safariViewController = SFSafariViewController(url: urlToOpen)
                        
                        safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
                        self.present(safariViewController, animated: true, completion: nil)
                    }
                default:
                    break
                }
            }
            cell.descriptionLabel.attributedText = (dosingInfo.content ?? "").styleAll(all).styleLinks(link)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, indicationCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        
        if let cell = cell as? KPInfoTableViewCell, let drug = drug {
            let info = drug.indications[indexPath.row]
            
            cell.titleLabel.text = info.title
            
            let descriptionParagraphStyle = NSMutableParagraphStyle()
            descriptionParagraphStyle.lineSpacing = 1.5
            descriptionParagraphStyle.lineBreakMode = .byWordWrapping
            
            cell.descriptionLabel.numberOfLines = 0
            let link = Style
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .normal)
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .highlighted)
            let all = Style.font(.systemFont(ofSize: 15))
                .foregroundColor(UIColor(named: KPConstants.Color.GlobalBlack)!)
                .paragraphStyle(descriptionParagraphStyle)
            
            cell.descriptionLabel.onClick = { label, detection in
                switch detection.type {
                case .link(let url):
                    var urlToOpen = url
                    
                    if urlToOpen.scheme == nil {
                        urlToOpen = URL(string: "https://".appending(urlToOpen.absoluteString)) ?? url
                    }
                    
                    if ["http", "https"].contains(urlToOpen.scheme?.lowercased() ?? "") {
                        let safariViewController = SFSafariViewController(url: urlToOpen)
                        
                        safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
                        self.present(safariViewController, animated: true, completion: nil)
                    }
                default:
                    break
                }
            }
            cell.descriptionLabel.attributedText = (info.content ?? "").styleAll(all).styleLinks(link)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   contraindicationCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        
        if let cell = cell as? KPInfoTableViewCell, let drug = drug {
            let info = drug.contraindications[indexPath.row]
            
            cell.titleLabel.text = info.title
            
            let descriptionParagraphStyle = NSMutableParagraphStyle()
            descriptionParagraphStyle.lineSpacing = 1.5
            descriptionParagraphStyle.lineBreakMode = .byWordWrapping
            
            cell.descriptionLabel.numberOfLines = 0
            let link = Style
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .normal)
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .highlighted)
            let all = Style.font(.systemFont(ofSize: 15))
                .foregroundColor(UIColor(named: KPConstants.Color.GlobalBlack)!)
                .paragraphStyle(descriptionParagraphStyle)
            
            cell.descriptionLabel.onClick = { label, detection in
                switch detection.type {
                case .link(let url):
                    var urlToOpen = url
                    
                    if urlToOpen.scheme == nil {
                        urlToOpen = URL(string: "https://".appending(urlToOpen.absoluteString)) ?? url
                    }
                    
                    if ["http", "https"].contains(urlToOpen.scheme?.lowercased() ?? "") {
                        let safariViewController = SFSafariViewController(url: urlToOpen)
                        
                        safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
                        self.present(safariViewController, animated: true, completion: nil)
                    }
                default:
                    break
                }
            }
            cell.descriptionLabel.attributedText = (info.content ?? "").styleAll(all).styleLinks(link)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, precautionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        
        if let cell = cell as? KPInfoTableViewCell, let drug = drug {
            let info = drug.precautions[indexPath.row]
            
            cell.titleLabel.text = info.title
            
            let descriptionParagraphStyle = NSMutableParagraphStyle()
            descriptionParagraphStyle.lineSpacing = 1.5
            descriptionParagraphStyle.lineBreakMode = .byWordWrapping
            
            cell.descriptionLabel.numberOfLines = 0
            let link = Style
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .normal)
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .highlighted)
            let all = Style.font(.systemFont(ofSize: 15))
                .foregroundColor(UIColor(named: KPConstants.Color.GlobalBlack)!)
                .paragraphStyle(descriptionParagraphStyle)
            
            cell.descriptionLabel.onClick = { label, detection in
                switch detection.type {
                case .link(let url):
                    var urlToOpen = url
                    
                    if urlToOpen.scheme == nil {
                        urlToOpen = URL(string: "https://".appending(urlToOpen.absoluteString)) ?? url
                    }
                    
                    if ["http", "https"].contains(urlToOpen.scheme?.lowercased() ?? "") {
                        let safariViewController = SFSafariViewController(url: urlToOpen)
                        
                        safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
                        self.present(safariViewController, animated: true, completion: nil)
                    }
                default:
                    break
                }
            }
            cell.descriptionLabel.attributedText = (info.content ?? "").styleAll(all).styleLinks(link)
        }
        
        return cell
    }
    
   func tableView(_ tableView: UITableView, moreInfoCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        
        if let cell = cell as? KPInfoTableViewCell, let drug = drug {
            let info = drug.moreInfo[indexPath.row]
            
            cell.titleLabel.text = info.title
            
            let descriptionParagraphStyle = NSMutableParagraphStyle()
            descriptionParagraphStyle.lineSpacing = 1.5
            descriptionParagraphStyle.lineBreakMode = .byWordWrapping
            
            cell.descriptionLabel.numberOfLines = 0
            let link = Style
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .normal)
                .foregroundColor(Color(named: KPConstants.Color.GlobalYellow)!, .highlighted)
            let all = Style.font(.systemFont(ofSize: 15))
                .foregroundColor(UIColor(named: KPConstants.Color.GlobalBlack)!)
                .paragraphStyle(descriptionParagraphStyle)
            
            cell.descriptionLabel.onClick = { label, detection in
                switch detection.type {
                case .link(let url):
                    var urlToOpen = url
                    
                    if urlToOpen.scheme == nil {
                        urlToOpen = URL(string: "https://".appending(urlToOpen.absoluteString)) ?? url
                    }
                    
                    if ["http", "https"].contains(urlToOpen.scheme?.lowercased() ?? "") {
                        let safariViewController = SFSafariViewController(url: urlToOpen)
                        
                        safariViewController.preferredControlTintColor = UIColor(named: KPConstants.Color.GlobalBlack)
                        self.present(safariViewController, animated: true, completion: nil)
                    }
                default:
                    break
                }
            }
            cell.descriptionLabel.attributedText = (info.content ?? "").styleAll(all).styleLinks(link)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, copayCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CopayCell", for: indexPath)
        if let cell = cell as? KPCopayCardTableViewCell, let drug = drug {
            cell.configure(drug)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, pharmacyCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PharmacyCell", for: indexPath)
        if let cell = cell as? KPPharmacyTableViewCell, let drug = drug {
            let pharmacy = drug.preferredPharmacies[indexPath.row]
            
            if let realm = drug.realm {
                let pricing = realm.objects(KPPricing.self).filter(NSPredicate(format: "drug == %@ AND pharmacy == %@",
                                                                               drug, pharmacy)).first
                cell.configure(pharmacy, pricing)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, contactCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        if let cell = cell as? KPContactTableViewCell {
            let contactItem = contactItems[indexPath.row]
            cell.contactLabel.text = contactItem.title
            cell.contactLabel.textColor = contactItem.color
            cell.contactImageView.image = contactItem.image
            cell.contactContainerView.layer.shadowColor = contactItem.color.cgColor
        }
        return cell
    }
}

extension KPDrugInfoTableViewController: KPContactViewControllerDelegate {
    func didPressContactButton() {
        guard let selectedContactItem = selectedContactItem else { return }
        
        let contactString = selectedContactItem.link
        let contactTitle = selectedContactItem.title
        let contactPrimaryColor = selectedContactItem.color
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link]
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            detector.enumerateMatches(in: contactString,
                                      options: [],
                                      range: NSRange(location: 0, length: contactString.count)) { (result, _, _) in
                                        if result?.resultType == .phoneNumber {
                                            if let phoneNumber = result?.phoneNumber,
                                                let url = URL(string: "tel://\(phoneNumber.onlyDigits())"),
                                                UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            }
                                        } else if result?.resultType == .link {
                                            if result?.url?.scheme == "mailto" {
                                                guard MFMailComposeViewController.canSendMail()
                                                    else { return }
                                                
                                                let composeVC = MFMailComposeViewController()
                                                composeVC.setToRecipients([contactString])
                                                composeVC.setSubject(contactTitle)
                                                composeVC.mailComposeDelegate = self
                                                present(composeVC, animated: true, completion: nil)
                                            } else if let url = result?.url {
                                                let safariController = SFSafariViewController(url: url)
                                                
                                                safariController
                                                    .preferredControlTintColor = contactPrimaryColor
                                                present(safariController,
                                                        animated: true,
                                                        completion: nil)
                                            }
                                        }
            }
        } catch {
        }
    }
}

extension KPDrugInfoTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension KPDrugInfoTableViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let advertisement = selectedAdvertisement {
            KPImpressionStore.sharedStore.recordView(advertisement.id,
                                                     advertisement.advertisementId ?? "",
                                                     .advertisement,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
    }
}
