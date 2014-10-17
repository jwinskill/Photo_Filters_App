//
//  ViewController.swift
//  PhotoFilterApp
//
//  Created by Joshua Winskill on 10/13/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import UIKit
import CoreImage
import OpenGLES
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GalleryDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterThumbnailsCollectionView: UICollectionView!
    
    // Constraint Outlets
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var photosButtonBottomConstraint: NSLayoutConstraint!

    // Properties for filtering
    var context: CIContext?
    var originalThumbnail: UIImage?
 //   var filterNames = [String]()
    var filters = [Filter]()
    var imageQueue = NSOperationQueue()
    var filterThumbnails = [FilteredThumbnail]()
    
    
    // Start functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateThumbnail()
        var options = [kCIContextWorkingColorSpace: NSNull()]
        var eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.context = CIContext(EAGLContext: eaglContext, options: options)
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var seeder = CoreDataSeeder(context: appDelegate.managedObjectContext!)

        self.fetchFilters()
        if self.filters.isEmpty {
            seeder.seedCoreData()
            self.fetchFilters()
        }
        self.resetFilterThumbnails()
        self.filterThumbnailsCollectionView.reloadData()
        
        self.filterThumbnailsCollectionView.dataSource = self
        self.filterThumbnailsCollectionView.delegate = self
    }

    @IBAction func photosButtonPressed(sender: AnyObject) {
        
        // Create the alertController
        let alertController = UIAlertController(title: nil, message: "Choose an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // Create UIAlertActions to add to the alertController
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                
            }
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
        let photosAction = UIAlertAction(title: "Photos Framework", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("PHOTOS_SEGUE", sender: self)
        }
        let avFoundationAction = UIAlertAction(title: "AVFoundation Framework", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("AVFOUNDATION_SEGUE", sender: self)
        }
        
        let filterAction = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.enterFilterMode()
        }

        // Add the UIAlertActions to the alertController
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photosAction)
        alertController.addAction(filterAction)
        alertController.addAction(avFoundationAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        } else if segue.identifier == "PHOTOS_SEGUE" {
            let destinationVC = segue.destinationViewController as PhotosFrameworkViewController
            destinationVC.delegate = self
            destinationVC.assetLargeImageSize = self.imageView.bounds.size
            println(self.imageView.bounds.size)
        } else if segue.identifier == "AVFOUNDATION_SEGUE" {
            let destinationVC = segue.destinationViewController as AVFoundationCameraViewController
            destinationVC.delegate = self
        }
    }
    
    // MARK: Filter Methods
    
    func enterFilterMode() {
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant * 3
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant * 3
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant * 3
        self.collectionViewBottomConstraint.constant = 46
        self.photosButtonBottomConstraint.constant = -100
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func exitFilterMode() {
        
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant / 3
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant / 3
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant / 3
        self.collectionViewBottomConstraint.constant = -100
        self.photosButtonBottomConstraint.constant = 8
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func generateThumbnail() {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    // MARK: UICollectionViewDataSource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterThumbnails.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("THUMBNAIL_CELL", forIndexPath: indexPath) as FilterThumbnailsCollectionViewCell
        
        var filterThumbnail = self.filterThumbnails[indexPath.row]
        
        if filterThumbnail.filteredThumbnail != nil {
            cell.thumbnailImageView.image = filterThumbnail.filteredThumbnail
        } else {
            cell.thumbnailImageView.image = filterThumbnail.originalThumbnail
            filterThumbnail.applyFilter({ (image) -> Void in
                cell.thumbnailImageView.image = image
            })
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate Method
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var filteredThumbnail = FilteredThumbnail(name: self.filters[indexPath.row].name, thumbnail: self.imageView.image!, queue: imageQueue, context: self.context!)
        filteredThumbnail.applyFilter({ (image) -> Void in
            self.imageView.image = image
        })
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.filterThumbnailsCollectionView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: GalleryDelegate Methods
    
    func didTapOnPicture(image: UIImage) {
        self.imageView.image = image
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.filterThumbnailsCollectionView.reloadData()
    }
    
    // MARK: CoreData Methods
    
    func fetchFilters() {
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context = appDelegate.managedObjectContext
        var error: NSError?
        var fetchResults = context?.executeFetchRequest(fetchRequest, error: &error)
        if let filters = fetchResults as? [Filter] {
            self.filters = filters
        }
    }
    
    func resetFilterThumbnails() {
        var newFilters = [FilteredThumbnail]()
        for var i = 0; i < self.filters.count; i++ {
            var filter = self.filters[i]
            var filterName = filter.name
            var thumbnail = FilteredThumbnail(name: filterName, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: context!)
            newFilters.append(thumbnail)
        }
        self.filterThumbnails = newFilters
    }

}

