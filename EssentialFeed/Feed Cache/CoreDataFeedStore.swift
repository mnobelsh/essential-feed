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
            do {
                try ManagedCache.find(in: context).map(context.delete(_:)).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
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
                    completion(.success(CachedFeed(feed: managedCache.localFeed, timestamp: managedCache.timestamp)))
                } else {
                    completion(.success(.none))
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
