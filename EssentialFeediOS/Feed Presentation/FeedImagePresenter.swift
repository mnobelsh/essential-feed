//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 16/12/24.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    private var task: FeedImageDataLoaderTask?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    struct InvalidImageDataError: Error {}
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                image: nil,
                location: model.location,
                description: model.description,
                isLoading: true,
                shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        view.display(
            FeedImageViewModel(
                image: image,
                location: model.location,
                description: model.description,
                isLoading: false,
                shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                image: nil,
                location: model.location,
                description: model.description,
                isLoading: false,
                shouldRetry: true)
        )
    }
}
