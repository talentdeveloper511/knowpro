//
//  KPSearchTableViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/17/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import TPKeyboardAvoiding

class KPSearchTableViewController: UITableViewController {
    
    // MARK: - Controller Properties
    
    private var searchResults: [Object] = []
    
    var searchText = "" {
        didSet {
            if searchText == "" {
                searchResults = []
                tableView.reloadData()
                return
            }
            
            do {
                let realm = try Realm()
                let drugFormatString =
"""
name CONTAINS[cd] %@ OR \
info CONTAINS[cd] %@ OR \
ANY indications.title CONTAINS[cd] %@ OR \
ANY indications.content CONTAINS[cd] %@ OR \
ANY precautions.title CONTAINS[cd] %@ OR \
ANY precautions.content CONTAINS[cd] %@ OR \
ANY contraindications.title CONTAINS[cd] %@ OR \
ANY contraindications.content CONTAINS[cd] %@ OR \
ANY dosageInformation.title CONTAINS[cd] %@ OR \
ANY dosageInformation.content CONTAINS[cd] %@ OR \
ANY moreInfo.title CONTAINS[cd] %@ OR \
ANY moreInfo.content CONTAINS[cd] %@
"""
                searchResults = []
                let drugs = realm.objects(KPDrug.self).filter(NSPredicate(format: drugFormatString,
                                                                          searchText, searchText, searchText,
                                                                          searchText, searchText, searchText,
                                                                          searchText, searchText, searchText,
                                                                          searchText, searchText, searchText))
                let companies = realm.objects(KPCompany.self)
                    .filter(NSPredicate(format: "name CONTAINS[cd] %@ OR info CONTAINS[cd] %@", searchText, searchText))
                
                for drug in drugs {
                    searchResults.append(drug)
                }
                
                for company in companies {
                    searchResults.append(company)
                }
                
                searchResults.sort { (firstObject, secondObject) -> Bool in
                    var nameA = ""
                    var nameB = ""
                    
                    if let firstObject = firstObject as? KPDrug {
                        nameA = firstObject.name ?? ""
                    } else if let firstObject = firstObject as? KPCompany {
                        nameA = firstObject.name ?? ""
                    }
                    
                    if let secondObject = secondObject as? KPDrug {
                        nameB = secondObject.name ?? ""
                    } else if let secondObject = secondObject as? KPCompany {
                        nameB = secondObject.name ?? ""
                    }
                    
                    return nameA.compare(nameB) == ComparisonResult.orderedAscending
                }
                
                tableView.reloadData()
                
            } catch {
                
                searchResults = []
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrugCell", for: indexPath)
        
        // Configure the cell...
        if let cell = cell as? KPDrugTableViewCell {
            
            if let drug = searchResult as? KPDrug {
                KPImpressionStore.sharedStore.recordImpression(drug.id, drug.name ?? "", .drug)

                cell.configure(drug)
            } else if let company = searchResult as? KPCompany {
                KPImpressionStore.sharedStore.recordImpression(company.id, company.name ?? "", .company)

                cell.configure(company)
            }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchResult = searchResults[indexPath.row]
        
        if searchResult is KPDrug {
            performSegue(withIdentifier: "DrugSegue", sender: searchResult)
        } else if searchResult is KPCompany {
            performSegue(withIdentifier: "CompanySegue", sender: searchResult)
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
        
        if let drug = sender as? KPDrug,
            let destination = segue.destination as? KPDrugViewController {
            destination.drug = drug
        } else if let company = sender as? KPCompany,
            let destination = segue.destination as? KPCompanyViewController {
            destination.company = company
        }
    }
}
