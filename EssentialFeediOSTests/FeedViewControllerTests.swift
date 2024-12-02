//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Muhammad Nobel Shidqi on 01/12/24.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0)
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
        
        sut.simulateUserInitiateFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
        
        sut.simulateUserInitiateFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiateFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiateFeedReload()
        loader.completeFeedLoading(with: anyNSError(), at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeFeedImage(description: "Description 0", location: "Location 0")
        let image1 = makeFeedImage(description: "Description 1", location: "Location 1")
        let image2 = makeFeedImage(description: "Description 2", location: "Location 2")
        let image3 = makeFeedImage(description: "Description 3", location: "Location 3")
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiateFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeFeedImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiateFeedReload()
        loader.completeFeedLoading(with: anyNSError(), at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeFeedImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeFeedImage(url: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelsImageURLWhenNotVisibleAnymore() {
        let image0 = makeFeedImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeFeedImage(url: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeFeedImage(), makeFeedImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoading(with: Data(), at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeFeedImage(), makeFeedImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage?.count, imageData0.count)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage?.count, imageData0.count)
        XCTAssertEqual(view1?.renderedImage?.count, imageData1.count)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeFeedImage(), makeFeedImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        
        loader.completeImageLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, true)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeFeedImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        
        let invalidImageData0 = "Invalid image data".data(using: .utf8)!
        loader.completeImageLoading(with: invalidImageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, true)
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeFeedImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeFeedImage(url: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
        
        loader.completeImageLoading(with: anyNSError(), at: 0)
        loader.completeImageLoading(with: anyNSError(), at: 1)
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url])
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url])
    }

}

// MARK: - Helpers
extension FeedViewControllerTests {
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    func makeFeedImage(description: String? = nil, location: String? = nil, url: URL = anyURL()) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance. got \(String(describing: view)) instead.", file: file, line: line)
        }
        
        XCTAssertEqual(cell.isShowingLocation, image.location != nil, file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location, file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, file: file, line: line)
    }
    
    func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }

        feed.enumerated().forEach {
            assertThat(sut, hasViewConfiguredFor: $1, at: $0, file: file, line: line)
        }
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {

        // MARK: - FeedLoader
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        var loadFeedCallCount: Int { feedRequests.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoading(with error: Error, at index: Int = 0) {
            feedRequests[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedImageURLs: [URL] { imageRequests.map(\.url) }
        private(set) var cancelledImageURLs: [URL] = []
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            var cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with data: Data, at index: Int = 0) {
            imageRequests[index].completion(.success(data))
        }
        
        func completeImageLoading(with error: Error, at index: Int = 0) {
            imageRequests[index].completion(.failure(error))
        }
    }
    
}

private extension FeedViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    var feedImageSection: Int { 0 }
    
    func simulateUserInitiateFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at row: Int) {
        let cell = simulateFeedImageViewVisible(at: row)!
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceUIRefreshControlForiOS17Support()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceUIRefreshControlForiOS17Support() {
        let fakeRefreshControl = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        self.refreshControl = fakeRefreshControl
    }
    
    class FakeRefreshControl: UIRefreshControl {
        private var _isRefreshing: Bool = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool { !locationContainer.isHidden }
    
    var locationText: String? { locationLabel.text }
    
    var descriptionText: String? { descriptionLabel.text }
    
    var isShowingImageLoadingIndicator: Bool { feedImageContainer.isShimmering }
    
    var renderedImage: Data? { feedImageView.image?.pngData() }
    
    var isShowingRetryAction: Bool { !feedImageRetryButton.isHidden }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateOnTap()
    }
}

extension UIButton {
    func simulateOnTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach{ action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
    
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50))
        return renderer.image { context in
            let size = renderer.format.bounds.size
            color.setFill()
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.fill(rect)
        }
    }
}
