//
//  FeedUIIntegrationTests.swift
//  StargazersiOSTests
//
//  Created by Riccardo Rossi - Home on 26/01/22.
//

import XCTest
@testable import StargazersiOS
import Stargazers

class StargazersUIIntegrationTests: XCTestCase {
    
    func test_stargazersViewController_hasRightTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
                
        XCTAssertEqual(sut.title, localized("STARGAZERS_VIEW_TITLE"))
    }
    
    func test_viewController_loadsStargazersForSelectedRepository() {
        let selectedRepository = uniqueRepository()
        let (sut, spy) = makeSUT(for: selectedRepository)

        sut.loadViewIfNeeded()
        XCTAssertEqual(spy.repositoryForLoad(at: 0), selectedRepository)
        
        sut.simulateUserInitiatedPullToRefresh()
        XCTAssertEqual(spy.repositoryForLoad(at: 1), selectedRepository)
    }
    
    func test_viewController_loadsStargazersWhenLoadedOrOnPullToRefresh() {
        let (sut, spy) = makeSUT()
        XCTAssertEqual(spy.stargazersLoadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(spy.stargazersLoadCallCount, 1)
        
        sut.simulateUserInitiatedPullToRefresh()
        XCTAssertEqual(spy.stargazersLoadCallCount, 2)
        
        sut.simulateUserInitiatedPullToRefresh()
        XCTAssertEqual(spy.stargazersLoadCallCount, 3)
    }
    
    func test_viewController_showsLoadingIndicatorWhileLoading() {
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.loadingIndicatorEnabled)
        
        spy.completeLoading(at: 0)
        XCTAssertFalse(sut.loadingIndicatorEnabled)
        
        sut.simulateUserInitiatedPullToRefresh()
        XCTAssertTrue(sut.loadingIndicatorEnabled)
        
        spy.completeLoading(at: 1)
        XCTAssertFalse(sut.loadingIndicatorEnabled)
        
        sut.simulateUserInitiatedPullToRefresh()
        XCTAssertTrue(sut.loadingIndicatorEnabled)
        
        spy.completeLoadingWithError(at: 2)
        XCTAssertFalse(sut.loadingIndicatorEnabled)
    }
    
    func test_viewController_showsLoadingIndicatorWhileUserImageIsLoading() {
        let (sut, spy) = makeSUT()
        let stargazer0 = uniqueStargazer()
        let stargazer1 = uniqueStargazer()

        sut.loadViewIfNeeded()
        spy.completeLoading(with: [stargazer0, stargazer1])
        let stargazerCell0 = sut.simulateStargazerViewVisible(at: 0)
        let stargazerCell1 = sut.simulateStargazerViewVisible(at: 1)
        
        XCTAssertEqual(stargazerCell0?.imageLoadingIndicatorEnabled, true)
        XCTAssertEqual(stargazerCell1?.imageLoadingIndicatorEnabled, true)
        
        spy.completeImageLoadingWithSuccess(at: 1)
        
        XCTAssertEqual(stargazerCell0?.imageLoadingIndicatorEnabled, true)
        XCTAssertEqual(stargazerCell1?.imageLoadingIndicatorEnabled, false)
        
        spy.completeImageLoadingWithError(at: 0)
        
        XCTAssertEqual(stargazerCell0?.imageLoadingIndicatorEnabled, false)
        XCTAssertEqual(stargazerCell1?.imageLoadingIndicatorEnabled, false)
    }
    
    func test_viewController_successfullyRendersLoadedStargazers() {
        let stargazer0 = uniqueStargazer()
        let stargazer1 = uniqueStargazer()
        let stargazer2 = uniqueStargazer()
        let stargazer3 = uniqueStargazer()
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, hasRendered: [])
        
        spy.completeLoading(with: [stargazer0], at: 0)
        assertThat(sut, hasRendered: [stargazer0])
        
        sut.simulateUserInitiatedPullToRefresh()
        spy.completeLoading(with: [stargazer0, stargazer1, stargazer2, stargazer3], at: 1)
        assertThat(sut, hasRendered: [stargazer0, stargazer1, stargazer2, stargazer3])
    }
    
    func test_viewController_doesNotAlterCurrentRenderingStateOnLoadingError() {
        let stargazer0 = uniqueStargazer()
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        spy.completeLoading(with: [stargazer0], at: 0)
        
        sut.simulateUserInitiatedPullToRefresh()
        spy.completeLoadingWithError(at: 1)
        
        assertThat(sut, hasRendered: [stargazer0])
    }
    
    func test_viewController_showsAlertViewControllerOnLoadingError() throws {
        let (sut, spy) = makeFakePresentationSUT()
        
        sut.loadViewIfNeeded()
        
        spy.completeLoadingWithError()
        
        let alertViewController = try XCTUnwrap(sut.viewControllerToPresent as? UIAlertController)
        XCTAssertEqual(alertViewController.title, localized("STARGAZERS_LOADING_ERROR_TITLE"))
        XCTAssertEqual(alertViewController.message, localized("STARGAZERS_LOADING_ERROR_MESSAGE"))
        XCTAssertEqual(alertViewController.actions.count, 1)
        let action = try XCTUnwrap(alertViewController.actions.first)
        XCTAssertEqual(action.title, localized("STARGAZERS_LOADING_ERROR_OK_ACTION"))
    }
    
    func test_stargazerImageView_loadsUserImageURLWhenVisible() {
        let stargazer0 = makeStargazer(avatarURL: URL(string: "http://avatar0-image.com")!)
        let stargazer1 = makeStargazer(avatarURL: URL(string: "http://avatar1-image.com")!)
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        spy.completeLoading(with: [stargazer0, stargazer1], at: 0)
        XCTAssertEqual(spy.loadedImageURLs, [], "Expected no image URL requests until view become visible")
        
        sut.simulateStargazerViewVisible(at: 0)
        XCTAssertEqual(spy.loadedImageURLs, [stargazer0.avatarURL])
        
        sut.simulateStargazerViewVisible(at: 1)
        XCTAssertEqual(spy.loadedImageURLs, [stargazer0.avatarURL, stargazer1.avatarURL])
    }
    
    func test_stargazerImageView_cancelsUserImageURLWhenRemovedFromScreen() {
        let stargazer0 = makeStargazer(avatarURL: URL(string: "http://avatar0-image.com")!)
        let stargazer1 = makeStargazer(avatarURL: URL(string: "http://avatar1-image.com")!)
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        spy.completeLoading(with: [stargazer0, stargazer1], at: 0)
        XCTAssertEqual(spy.loadCanceledImageURLs, [], "Expected no image URL canceled until view become invisible")
        
        sut.simulateStargazerViewVisibleAndThenNotVisible(at: 0)
        XCTAssertEqual(spy.loadCanceledImageURLs, [stargazer0.avatarURL])
        
        sut.simulateStargazerViewVisibleAndThenNotVisible(at: 1)
        XCTAssertEqual(spy.loadCanceledImageURLs, [stargazer0.avatarURL, stargazer1.avatarURL])
    }
    
    func test_stargazerImageView_showsUserImageAfterCompleteImageLoadingWithSuccess() {
        let (sut, spy) = makeSUT()
        let stargazer0 = uniqueStargazer()
        let fakeUserImageData = UIImage.make(withColor: .red).pngData()!

        sut.loadViewIfNeeded()
        spy.completeLoading(with: [stargazer0])
        let stargazerCell0 = sut.simulateStargazerViewVisible(at: 0)
        
        XCTAssertEqual(stargazerCell0?.userImageData, .none)
        
        spy.completeImageLoadingWithSuccess(with: fakeUserImageData, at: 0)
        
        XCTAssertEqual(stargazerCell0?.userImageData, fakeUserImageData)
    }
    
    func test_stargazerImageView_showsNoImageWhenImageDataIsNotValid() {
        let (sut, spy) = makeSUT()
        let stargazer0 = uniqueStargazer()
        let nonValidUserImageData = "Any non related image data".data(using: .utf8)!

        sut.loadViewIfNeeded()
        spy.completeLoading(with: [stargazer0])
        let stargazerCell0 = sut.simulateStargazerViewVisible(at: 0)
        
        XCTAssertEqual(stargazerCell0?.userImageData, .none)
        
        spy.completeImageLoadingWithSuccess(with: nonValidUserImageData, at: 0)
        
        XCTAssertEqual(stargazerCell0?.userImageData, .none)
    }
    
    func test_stargazersViewController_doesNotRenderLoadedImageWhenCellNotVisibleAnymore() {
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        spy.completeLoading(with: [uniqueStargazer()])
        
        let stargazerCell = sut.simulateStargazerViewVisible(at: 0)
        sut.simulateStargazer(viewNotVisibleAnymore: stargazerCell!, at: 0)
        
        spy.completeImageLoadingWithSuccess(with: UIImage.make(withColor: .red).pngData()!, at: 0)
        
        XCTAssertEqual(stargazerCell?.userImageData, .none)
    }
    
    func test_stargazersViewController_dispatchesStargazersLoadingFromBackgroundToMainThread() {
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue to execute loading completion")
        DispatchQueue.global().async {
            spy.completeLoading()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_stargazersViewController_dispatchesImageLoadingCompletionFromBackgroundToMainThread() {
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        spy.completeLoading(with: [uniqueStargazer()])
        sut.simulateStargazerViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue to execute loading completion")
        DispatchQueue.global().async {
            spy.completeImageLoadingWithSuccess()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Utils
    
    private func makeSUT(
        for repository: Repository? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (StargazersViewController, LoaderSpy) {
        let repository = repository ?? anyRepository()
        let spy = LoaderSpy()
        let sut = StargazersUIComposer.composedWith(
            loader: spy,
            imageLoader: spy,
            repository: repository
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
    
    private func makeFakePresentationSUT(
        for repository: Repository? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (FakePresentationStargazersViewController, LoaderSpy) {
        let repository = repository ?? anyRepository()
        let spy = LoaderSpy()
        let loadViewModel = StargazersLoadViewModel(loader: spy, repository: repository)
        let refreshController = StargazersRefreshController(viewModel: loadViewModel)
        let errorController = StargazersErrorController(viewModel: loadViewModel)
        let sut = FakePresentationStargazersViewController(
            refreshController: refreshController,
            errorController: errorController
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
    
    private func makeStargazer(avatarURL: URL) -> Stargazer {
        let anyStargazer = anyStargazer()
        return Stargazer(
            id: anyStargazer.id,
            username: anyStargazer.username,
            avatarURL: avatarURL,
            detailURL: anyStargazer.detailURL
        )
    }
    
    private func assertThat(
        _ sut: StargazersViewController,
        hasViewConfiguredFor stargazer: Stargazer,
        at row: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let stargazerCell = sut.stargazerView(at: row) as? StargazerCell
        XCTAssertEqual(
            stargazerCell?.usernameText,
            stargazer.username,
            file: file,
            line: line
        )
    }
    
    private func assertThat(
        _ sut: StargazersViewController,
        hasRendered stargazers: [Stargazer],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            sut.renderedStargazerViews,
            stargazers.count,
            file: file,
            line: line
        )
        
        guard sut.renderedStargazerViews == stargazers.count else {
            return XCTFail("Expected \(stargazers.count) rendered views but got \(sut.renderedStargazerViews) instead", file: file, line: line)
        }
        
        stargazers.enumerated().forEach { index, stargazer in
            assertThat(
                sut,
                hasViewConfiguredFor: stargazer,
                at: index,
                file: file,
                line: line
            )
        }
    }
    
    private class LoaderSpy: StargazersLoader, StargazerImageLoader {
        
        // MARK: - Stargazers Loader
        
        var stargazersLoadCallCount: Int {
            return stargazersRequests.count
        }
        
        private var stargazersRequests = [(repository: Repository, completion: (StargazersLoader.Result) -> Void)]()
        
        func load(from repository: Repository, completion: @escaping (StargazersLoader.Result) -> Void) {
            stargazersRequests.append((repository, completion))
        }
        
        func completeLoading(with stargazers: [Stargazer] = [], at row: Int = 0) {
            stargazersRequests[row].completion(.success(stargazers))
        }
        
        func completeLoadingWithError(at row: Int = 0) {
            stargazersRequests[row].completion(.failure(anyNSError()))
        }
        
        func repositoryForLoad(at row: Int = 0) -> Repository {
            return stargazersRequests[row].repository
        }
        
        // MARK: - Image Loader
        
        private struct LoaderSpyTask: StargazerImageLoaderTask {
            let onCancel: () -> Void
            
            func cancel() {
                onCancel()
            }
        }
        
        var loadedImageURLs = [URL]()
        var loadCanceledImageURLs = [URL]()
        private var completions = [(StargazerImageLoader.Result) -> Void]()
        
        func loadImageData(from url: URL, completion: @escaping (StargazerImageLoader.Result) -> Void) -> StargazerImageLoaderTask {
            loadedImageURLs.append(url)
            completions.append(completion)
            return LoaderSpyTask(onCancel: { [weak self] in
                self?.loadCanceledImageURLs.append(url)
            })
        }
        
        func completeImageLoadingWithSuccess(with data: Data = Data(), at index: Int = 0) {
            completions[index](.success(data))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = anyNSError()
            completions[index](.failure(error))
        }
    }
    
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).performSelector(onMainThread: Selector(action), with: nil, waitUntilDone: true)
            }
        }
        
    }
}

private extension StargazersViewController {
    func simulateUserInitiatedPullToRefresh() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var loadingIndicatorEnabled: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    func stargazerView(at row: Int) -> UIView? {
        let indexPath = IndexPath(row: row, section: stargazersSection)
        return tableView.dataSource?.tableView(
            tableView,
            cellForRowAt: indexPath
        )
    }
    
    @discardableResult
    func simulateStargazerViewVisible(at row: Int) -> StargazerCell? {
        return stargazerView(at: row) as? StargazerCell
    }
    
    func simulateStargazer(viewNotVisibleAnymore view: StargazerCell, at row: Int) {
        let indexPath = IndexPath(row: row, section: stargazersSection)
        return tableView(
            tableView,
            didEndDisplaying: view,
            forRowAt: indexPath
        )
    }
    
    func simulateStargazerViewVisibleAndThenNotVisible(at row: Int) {
        let view = simulateStargazerViewVisible(at: row)
        simulateStargazer(viewNotVisibleAnymore: view!, at: row)
    }
    
    var renderedStargazerViews: Int {
        tableView.numberOfRows(inSection: stargazersSection)
    }
    
    private var stargazersSection: Int { 0 }
}

private extension StargazerCell {
    var usernameText: String? {
        usernameLabel.text
    }
    
    var imageLoadingIndicatorEnabled: Bool {
        isUserImageLoading
    }
    
    var userImageData: Data? {
        userImageView.image?.pngData()
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

private func localized(_ localizedKey: String, file: StaticString = #filePath, line: UInt = #line) -> String {
    let bundle = Bundle(for: StargazersViewController.self)
    let table = "Stargazers"
    let localizedTitle = bundle.localizedString(
        forKey: localizedKey,
        value: nil,
        table: table
    )
    if localizedKey == localizedTitle {
        XCTFail("Missing localized string for key: \(localizedKey) in table \(table)", file: file, line: line)
    }
    return localizedTitle
}

private class FakePresentationStargazersViewController: StargazersViewController {
    var viewControllerToPresent: UIViewController?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        self.viewControllerToPresent = viewControllerToPresent
    }
}
