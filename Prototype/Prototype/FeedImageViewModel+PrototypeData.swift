//
//  FeedImageViewModel+PrototypeData.swift
//  Prototype
//
//  Created by Muhammad Nobel Shidqi on 01/12/24.
//

import Foundation

extension FeedImageViewModel {
    static var prototypeFeed: [FeedImageViewModel] = [
        .init(
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            imageName: "image-1"
        ),
        .init(
            location: "United Kingdom,\nLondon",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            imageName: "image-2"
        ),
        .init(
            location: "Japan,\nTokyo",
            imageName: "image-3"
        ),
        .init(
            imageName: "image-4"
        ),
        .init(
            location: "Indonesia,\nJakarta",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
            imageName: "image-5"
        )
    ]
}
