//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 26/11/24.
//

import Foundation
import CoreData

extension NSPersistentContainer {
    enum Error: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, bundle: Bundle) throws -> NSPersistentContainer {
        guard let managedObjectModel = try NSManagedObjectModel.with(modelName: name, bundle: bundle) else {
            throw Error.modelNotFound
        }
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: managedObjectModel)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1}
        try loadError.map{ throw Error.failedToLoadPersistentStores($0) }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(modelName name: String, bundle: Bundle) throws -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd")
                    .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
