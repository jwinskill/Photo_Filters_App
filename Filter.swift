//
//  Filter.swift
//  PhotoFilterApp
//
//  Created by Joshua Winskill on 10/14/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var favorited: NSNumber

}
