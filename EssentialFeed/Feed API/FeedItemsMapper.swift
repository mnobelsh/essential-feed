//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 17/11/24.
//

import Foundation

final class FeedItemsMapper {
    private static var OK_200: Int { 200 }
    
    private struct Root: Decodable {
        let items: [RemoteFeedImage]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedImage] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
