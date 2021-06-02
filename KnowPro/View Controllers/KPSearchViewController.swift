//
//  KPSearchViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/4/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import SPLarkController

class KPSearchViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var searchBarWidth: NSLayoutConstraint!
    @IBOutlet private weak var searchField: UITextField!
    @IBOutlet private weak var searchTableViewContainer: UIView!
    
    // MARK: - Controller Properties
    
    private weak var searchTableViewController: KPSearchTableViewController?
    
    // MARK: - Actions
    
    @IBAction private func menuButtonPressed(_ sender: AnyObject) {
        searchField.resignFirstResponder()
        
        let controller = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "MenuViewController")
        let transitionDelegate = SPLarkTransitioningDelegate()
        transitionDelegate.customHeight = 308
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchBarWidth.constant = UIScreen.main.bounds.width * 0.797
        searchField.layer.shadowOffset = CGSize(width: 0, height: 8)
        searchField.layer.shadowColor = UIColor(red: 0.07, green: 0.47, blue: 0.85, alpha: 1).cgColor
        searchField.layer.shadowRadius = 16
        searchField.layer.shadowOpacity = 0
        
        for child in children where child is KPSearchTableViewController {
            searchTableViewController = child as? KPSearchTableViewController
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSearchField))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(forName: KPConstants.Notifications.TabSelected.name, object: nil, queue: .main) { (notification) in
            self.dismissSearchView()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Public Methods
    
    @objc func dismissSearchField() {
        searchField.resignFirstResponder()
    }
    
    @objc func dismissSearchView() {
        searchField.text = ""

        if searchField.isFirstResponder {
            searchField.resignFirstResponder()
        } else {
            searchField.layer.shadowOpacity = 0
            
            UIView.animate(withDuration: 0.2, animations: {
                self.searchTableViewContainer.alpha = 0
            }, completion: { _ in
                self.searchTableViewContainer.isHidden = true
            })
        }
        
        guard let searchTableViewController = searchTableViewController else { return }
        searchTableViewController.searchText = ""
    }

}

extension KPSearchViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTableViewContainer.isHidden = false
        searchField.layer.shadowOpacity = 0.1
        
        UIView.animate(withDuration: 0.2) {
            self.searchTableViewContainer.alpha = 1
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.text?.count ?? 0 == 0 else { return }
        searchField.layer.shadowOpacity = 0

        UIView.animate(withDuration: 0.2, animations: {
            self.searchTableViewContainer.alpha = 0
        }, completion: { _ in
            self.searchTableViewContainer.isHidden = true
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
                
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard let searchTableViewController = searchTableViewController else { return true }

        searchTableViewController.searchText = ""
        
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let searchTableViewController = searchTableViewController else { return true }
        
        if let range = Range(range, in: textField.text ?? ""),
            let searchString = textField.text?.replacingCharacters(in: range, with: string) {
            searchTableViewController.searchText = searchString
        } else {
            searchTableViewController.searchText = ""
        }
        
        return true
    }
}
