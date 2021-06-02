//
//  KPCompanyInfoTableViewController+Extensions.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/16/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation
import RealmSwift
import MessageUI
import SafariServices
import Atributika

extension KPCompanyInfoTableViewController {
    func tableView(_ tableView: UITableView, infoCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        if let cell = cell as? KPInfoTableViewCell, let company = company {
            cell.titleLabel.text = company.name
            
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
            cell.descriptionLabel.attributedText = (company.info ?? "").styleAll(all).styleLinks(link)
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
    
    func tableView(_ tableView: UITableView, drugCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrugCell", for: indexPath)
        if let cell = cell as? KPDrugTableViewCell, let drug = searchString.count > 0 ?
            company?.drugs.filter(NSPredicate(format: "name CONTAINS[cd] %@", searchString))[indexPath.row] :
            company?.drugs[indexPath.row] {
            KPImpressionStore.sharedStore.recordImpression(drug.id, drug.name ?? "", .drug)

            cell.configure(drug)
        }
        return cell
    }
}

extension KPCompanyInfoTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        searchString = ""
        
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if let range = Range(range, in: textField.text ?? ""),
            let searchString = textField.text?.replacingCharacters(in: range, with: string) {
            self.searchString = searchString
        } else {
            searchString = ""
        }
        
        return true
    }
}

extension KPCompanyInfoTableViewController: KPContactViewControllerDelegate {
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
                                                
                                                safariController.preferredControlTintColor = contactPrimaryColor
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

extension KPCompanyInfoTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension KPCompanyInfoTableViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let advertisement = selectedAdvertisement {
            KPImpressionStore.sharedStore.recordView(advertisement.id,
                                                     advertisement.advertisementId ?? "",
                                                     .advertisement,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
    }
}
