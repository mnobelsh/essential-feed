//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 26/11/24.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    static let modelName: String = "FeedStore"
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = Bundle(for: CoreDataFeedStore.self)) throws {
        container = try NSPersistentContainer.load(modelName: CoreDataFeedStore.modelName, url: storeURL, bundle: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete(_:)).map(context.save)
            })
        }
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                managedCache.timestamp = timestamp
                try context.save()
            })
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
