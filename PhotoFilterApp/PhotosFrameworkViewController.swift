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
    var assetCellSize: CGSize!
    var assetLargeImageSize: CGSize?
    var delegate: GalleryDelegate?
    var someImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageManager = PHCachingImageManager()
        self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.photosFrameworkCollectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Did Select")
        
        var scale = UIScreen.mainScreen().scale
        var assetSize = CGSizeMake(self.assetLargeImageSize!.width * scale, self.assetLargeImageSize!.height * scale)
        
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: assetSize, contentMode: PHImageContentMode.AspectFit, options: nil) { (image, info) -> Void in
            var placeHolder = image
            self.delegate?.didTapOnPicture(placeHolder)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}
