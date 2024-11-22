//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 23/11/24.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var item: FeedItem {
        return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}
