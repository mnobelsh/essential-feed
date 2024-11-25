//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 26/11/24.
//

import Foundation
import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}
