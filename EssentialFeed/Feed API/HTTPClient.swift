//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 17/11/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
