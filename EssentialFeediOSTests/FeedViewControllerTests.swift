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
        var loadedImageURLs: [URL] = []
        
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
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
    
    @discardableResult
    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func simulateFeedImageViewVisible(at index: Int) {
        feedImageView(at: index)
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
