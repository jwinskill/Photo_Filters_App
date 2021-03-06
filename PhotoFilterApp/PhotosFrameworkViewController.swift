//
//  PhotosFrameworkViewController.swift
//  PhotoFilterApp
//
//  Created by Joshua Winskill on 10/15/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import UIKit
import Photos

class PhotosFrameworkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var photosFrameworkCollectionView: UICollectionView!

    var imageManager: PHCachingImageManager!
    var assetsCollection: PHAssetCollection!
    var assetFetchResults: PHFetchResult!
    var flowLayout: UICollectionViewFlowLayout!
    var assetCellSize: CGSize!
    var assetLargeImageSize: CGSize?
    var delegate: GalleryDelegate?
    var someImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageManager = PHCachingImageManager()
        self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        var scale = UIScreen.mainScreen().scale
        self.flowLayout = self.photosFrameworkCollectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        var cellSize = self.flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        
        var pincher = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        self.photosFrameworkCollectionView.addGestureRecognizer(pincher)
        
        self.photosFrameworkCollectionView.delegate = self
    }
    
    // MARK: UICollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as PhotosFrameworkCell
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            if cell.tag == currentTag {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Did Select")
        
        var scale = UIScreen.mainScreen().scale
        var assetSize = CGSizeMake(self.assetLargeImageSize!.width * scale, self.assetLargeImageSize!.height * scale)
        
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: assetSize, contentMode: PHImageContentMode.AspectFit, options: nil) { (image, info) -> Void in

            self.delegate?.didTapOnPicture(image)
            return( )
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Pinch action methods
    
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
            self.photosFrameworkCollectionView.performBatchUpdates({ () -> Void in
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
}
