//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 26/11/24.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle) throws {
        guard let managedObjectModel = bundle.url(forResource: "FeedStore", withExtension: "momd")
            .flatMap ({ NSManagedObjectModel(contentsOf: $0) }) else {
            throw NSError(domain: "CoreDataFeedStore", code: 0)
        }
        let persistentStoreDescription = NSPersistentStoreDescription(url: storeURL)
        
        container = NSPersistentContainer(name: "FeedStore", managedObjectModel: managedObjectModel)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.performAndWait {
            let request = NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
            request.returnsObjectsAsFaults = false
            if let cache = try? context.fetch(request).first {
                let managedFeed = cache.feed.compactMap { $0 as? ManagedFeedImage }
                let localFeed = managedFeed.compactMap { LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url) }
                completion(.found(feed: localFeed, timestamp: cache.timestamp))
            } else {
                completion(.empty)
            }
        }
    }
}
