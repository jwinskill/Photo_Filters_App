//
//  FilteredThumbnail.swift
//  PhotoFilterApp
//
//  Created by Joshua Winskill on 10/14/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import UIKit


class FilteredThumbnail {
    
    var originalThumbnail: UIImage
    var filteredThumbnail: UIImage?
    var imageQueue: NSOperationQueue?
    var gpuContext: CIContext
    var filter: CIFilter?
    var filterName: String
    
    init(name: String, thumbnail: UIImage, queue: NSOperationQueue, context: CIContext) {
        self.filterName = name
        self.originalThumbnail = thumbnail
        self.imageQueue = queue
        self.gpuContext = context
    }

    func applyFilter(image: UIImage?, competionHandler: (image: UIImage) -> Void) {
        
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            
            var newImage: CIImage
            if image != nil {
                newImage = CIImage(image: image!)
            } else {
                newImage = CIImage(image: self.originalThumbnail)
            }

            self.filter = CIFilter(name: self.filterName)
            self.filter?.setDefaults()
            
            if self.filterName == "CIColorMonochrome" {
                self.filter!.setValue(CIColor(red: self.getRandomNumber(), green: self.getRandomNumber(), blue: self.getRandomNumber()), forKey: kCIInputColorKey)
            }
            
            self.filter?.setValue(newImage, forKey: kCIInputImageKey)
            
            var result = self.filter?.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            
            self.filteredThumbnail = UIImage(CGImage: imageRef)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                competionHandler(image: self.filteredThumbnail!)
            })
        })
    }
    
    func getRandomNumber() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
}