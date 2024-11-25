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

extension ManagedCache {
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try ManagedCache.find(in: context).map(context.delete(_:))
        return ManagedCache(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        guard let entityName = entity().name else { return nil }
        let request = NSFetchRequest<ManagedCache>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    var localFeed: [LocalFeedImage] {
        feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
}
