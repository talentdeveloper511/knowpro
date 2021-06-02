//
//  KPGalleryCollectionViewController.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/21/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import RealmSwift
import Lightbox

private let reuseIdentifier = "Cell"

class KPGalleryCollectionViewController: UICollectionViewController {
    
    var galleryImages: List<KPAsset>? {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = collectionView.bounds.size
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let itemSize = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
        if itemSize != collectionView.bounds.size {
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = collectionView.bounds.size
            collectionViewLayout.invalidateLayout()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImages?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryMediaCell", for: indexPath)
    
        // Configure the cell
        if let cell = cell as? KPGalleryCollectionViewCell {
            let defaultPlaceholderColor = UIColor(named: KPConstants.Color.GlobalFaintGrey)
            if let galleryImages = galleryImages {
                let galleryImage = galleryImages[indexPath.item]
                if let urlString = galleryImage.urlString, let url = URL(string: urlString) {
                    if galleryImage.fileType?.contains("video") ?? false {
                        cell.galleryImageView.image = UIColor(named: KPConstants.Color.GlobalBlack)?.image()
                    } else {
                        cell.galleryImageView.sd_setImage(with: url,
                                                          placeholderImage: defaultPlaceholderColor?.image())
                    }
                }
            }
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let galleryImages = galleryImages else { return }
        var lightboxImages: [LightboxImage] = []
        
        for galleryImage in galleryImages {
            if let urlString = galleryImage.urlString, let imageUrl = URL(string: urlString) {
                if galleryImage.fileType?.contains("video") ?? false {
                    lightboxImages.append(LightboxImage(image: UIImage(named: "LogoColor")!,
                                                        text: "",
                                                        videoURL: imageUrl))
                } else {
                    lightboxImages.append(LightboxImage(imageURL: imageUrl))
                }
            }
        }
        
        if lightboxImages.count > 0 {
            let controller = LightboxController(images: lightboxImages, startIndex: indexPath.item)
            controller.dynamicBackground = true
            controller.modalTransitionStyle = .crossDissolve
            controller.pageDelegate = self
            
            present(controller, animated: true, completion: nil)
        }
    }

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
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setCurrentPage()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            setCurrentPage()
        }
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setCurrentPage()
    }
    
    // MARK: - Private Methods
    
    private func setCurrentPage() {
        guard let parent = parent as? KPDrugViewController, let galleryImages = galleryImages else { return }
        
        parent.galleryPageControl.currentPage = Int(
            Float(collectionView.currentPage)
                / Float(galleryImages.count)
                * Float(parent.galleryPageControl.numberOfPages))
    }

}

extension KPGalleryCollectionViewController: LightboxControllerPageDelegate {
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .centeredHorizontally, animated: true)
    }
}
