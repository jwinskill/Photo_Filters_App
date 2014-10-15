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

    func applyFilter(competionHandler: (image: UIImage) -> Void) {
        
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            
            var image = CIImage(image: self.originalThumbnail)
            var imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            self.filter = imageFilter
            self.filteredThumbnail = UIImage(CGImage: imageRef)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                competionHandler(image: self.filteredThumbnail!)
            })
        })
    }
}