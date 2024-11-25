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
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete(_:))
                let managedCache = ManagedCache(context: context)
                managedCache.feed = NSOrderedSet(array: feed.map {
                    let managedFeedImage = ManagedFeedImage(context: context)
                    managedFeedImage.id = $0.id
                    managedFeedImage.imageDescription = $0.description
                    managedFeedImage.location = $0.location
                    managedFeedImage.url = $0.url
                    return managedFeedImage
                })
                managedCache.timestamp = timestamp
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let managedCache = try ManagedCache.find(in: context) {
                    completion(.found(feed: managedCache.localFeed, timestamp: managedCache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
