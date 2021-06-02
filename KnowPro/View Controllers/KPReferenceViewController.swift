//
//  KPReferenceViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/9/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import PDFKit
import RealmSwift

class KPReferenceViewController: UIViewController {
    
    // MARK: - Interface Properties
    
    @IBOutlet private weak var pdfView: PDFView!
    
    // MARK: - Controller Properties
    
    private var pdfURL: URL?
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configurePDF()
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
    
    private func configurePDF() {
        do {
            let realm = try Realm()
            if let references = realm.objects(KPReferences.self).sorted(byKeyPath: "updatedAt", ascending: false).first,
                let pdfURL = references.pdfURL(), self.pdfURL != pdfURL {
                self.pdfURL = pdfURL
                pdfView.autoScales = true
                pdfView.displayMode = .singlePageContinuous
                pdfView.displaysPageBreaks = true
                pdfView.document = PDFDocument(url: pdfURL)
                pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
                }
        } catch {
        }
    }

}
