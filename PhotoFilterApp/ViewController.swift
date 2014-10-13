//
//  ViewController.swift
//  PhotoFilterApp
//
//  Created by Joshua Winskill on 10/13/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryDelegate {
    
    @IBOutlet weak var imageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
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

        // Add the UIAlertActions to the alertController
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapOnPicture(image: UIImage) {
        println("Hey, you tapped on that picture")
        self.imageView.image = image
    }

}

