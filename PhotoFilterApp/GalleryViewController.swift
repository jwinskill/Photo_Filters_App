//
//  GalleryViewController.swift
//  PhotoFilterApp
//
//  Created by Joshua Winskill on 10/13/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import UIKit
import Photos

protocol GalleryDelegate {
    
    func didTapOnPicture(image: UIImage)

}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var flowLayout: UICollectionViewFlowLayout!
    var images = [UIImage]()
    var delegate: GalleryDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var pincher = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        self.collectionView.addGestureRecognizer(pincher)
        
        let image1 = UIImage(named: "Photo1.jpg")
        let image2 = UIImage(named: "Photo2.jpg")
        let image3 = UIImage(named: "Photo3.jpeg")
        let image4 = UIImage(named: "Photo4.jpg")
        let image5 = UIImage(named: "Photo5.jpeg")
        let image6 = UIImage(named: "Photo6.jpeg")
        let image7 = UIImage(named: "Photo7.jpeg")
        let image8 = UIImage(named: "Photo8.jpg")
        let image9 = UIImage(named: "Photo9.jpeg")
        let image10 = UIImage(named: "Photo10.jpg")
        let image11 = UIImage(named: "Photo11.jpeg")
        let image12 = UIImage(named: "Photo12.jpeg")
        let image13 = UIImage(named: "Photo13.jpeg")
        let image14 = UIImage(named: "Photo14.jpeg")
        let image15 = UIImage(named: "Photo15.jpeg")
        let image16 = UIImage(named: "Photo16.jpeg")
        let image17 = UIImage(named: "Photo17.jpeg")
        
        self.images.append(image1)
        self.images.append(image2)
        self.images.append(image3)
        self.images.append(image4)
        self.images.append(image5)
        self.images.append(image6)
        self.images.append(image7)
        self.images.append(image8)
        self.images.append(image9)
        self.images.append(image10)
        self.images.append(image11)
        self.images.append(image12)
        self.images.append(image13)
        self.images.append(image14)
        self.images.append(image15)
        self.images.append(image16)
        self.images.append(image17)
    }
    
    func pinchAction(pincher: UIPinchGestureRecognizer) {
        
        var screen = UIScreen.mainScreen()
        var orientation = UIDevice.currentDevice().orientation.isPortrait
        var width: CGFloat!
        var height: CGFloat!
        if orientation {
            width = screen.bounds.width
            height = screen.bounds.height
        } else {
            width = screen.bounds.height
            height = screen.bounds.width
        }
        
        if pincher.state == UIGestureRecognizerState.Ended {
            self.collectionView.performBatchUpdates({ () -> Void in
                if pincher.velocity > 0 {
                    if (self.flowLayout.itemSize.width < width / 2) && (self.flowLayout.itemSize.height < height) {
                        self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 2, height: self.flowLayout.itemSize.height * 2)
                    }
                } else {
                    if (self.flowLayout.itemSize.width > width / 10) && (self.flowLayout.itemSize.height > height / 10) {
                        self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 0.5, height: self.flowLayout.itemSize.width * 0.5)
                    }
                }
            }, completion: nil)
        }
    }

    
    // MARK: UICollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        cell.cellImageView.image = self.images[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didTapOnPicture(self.images[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
