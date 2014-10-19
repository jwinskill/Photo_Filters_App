//
//  CoreDataSeeder.swift
//  PhotoFilterApp
//
//  Created by Joshua Winskill on 10/14/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import Foundation
import CoreData

class CoreDataSeeder {
    var managedObjectContext: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func seedCoreData() {
        var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepia.name = "CISepiaTone"
    
        var photoEffectTonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTonal.name = "CIPhotoEffectTonal"
        photoEffectTonal.favorited = true
        
        var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        pixellate.name = "CIPixellate"
        pixellate.favorited = false
        
        var colorPosterize = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        colorPosterize.name = "CIColorPosterize"
        colorPosterize.favorited = true
        
        var glassDistortion = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        glassDistortion.name = "CIGlassDistortion"
        glassDistortion.favorited = true
        
        var photoEffectTransfer = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTransfer.name = "CIPhotoEffectTransfer"
        photoEffectTransfer.favorited = true
        
        var process = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        process.name = "CIPhotoEffectProcess"
        process.favorited = true
        
        var photoEffectInstant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectInstant.name = "CIPhotoEffectInstant"
        
        var photoEffectNoir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectNoir.name = "CIPhotoEffectNoir"
        photoEffectNoir.favorited = true
        
        var monochrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        monochrome.name = "CIColorMonochrome"
        monochrome.favorited = false
        

    
        var error: NSError?
        self.managedObjectContext?.save(&error)
    }
}
