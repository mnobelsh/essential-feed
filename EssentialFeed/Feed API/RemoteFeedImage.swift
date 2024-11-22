//
//  RemoteFeedImage.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 23/11/24.
//

import Foundation

struct RemoteFeedImage: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
