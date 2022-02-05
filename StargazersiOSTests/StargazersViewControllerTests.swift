//
//  StargazersViewControllerTests.swift
//  StargazersiOSTests
//
//  Created by Riccardo Rossi - Home on 26/01/22.
//

import XCTest
import StargazersiOS
import Stargazers

class StargazersViewControllerTests: XCTestCase {
    
    func test_viewController_loadsStargazersForSelectedRepository() {
        let selectedRepository = uniqueRepository()
        let (sut, spy) = makeSUT(for: selectedRepository)

        sut.loadViewIfNeeded()
        XCTAssertEqual(spy.repositoryForLoad(at: 0), selectedRepository)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(spy.repositoryForLoad(at: 1), selectedRepository)
    }
    
    func test_viewController_loadsStargazersWhenLoadedOrOnPullToRefresh() {
        let (sut, spy) = makeSUT()
        XCTAssertEqual(spy.stargazersLoadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(spy.stargazersLoadCallCount, 1)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(spy.stargazersLoadCallCount, 2)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(spy.stargazersLoadCallCount, 3)
    }
    
    func test_viewController_showsLoadingIndicatorWhileLoading() {
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.loadingIndicatorEnabled)
        
        spy.completeLoading(at: 0)
        XCTAssertFalse(sut.loadingIndicatorEnabled)
        
        sut.simulatePullToRefresh()
        XCTAssertTrue(sut.loadingIndicatorEnabled)
        
        spy.completeLoading(at: 1)
        XCTAssertFalse(sut.loadingIndicatorEnabled)
        
        sut.simulatePullToRefresh()
        XCTAssertTrue(sut.loadingIndicatorEnabled)
        
        spy.completeLoadingWithError(at: 2)
        XCTAssertFalse(sut.loadingIndicatorEnabled)
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
        
        sut.simulatePullToRefresh()
        spy.completeLoading(with: [stargazer0, stargazer1, stargazer2, stargazer3], at: 1)
        assertThat(sut, hasRendered: [stargazer0, stargazer1, stargazer2, stargazer3])
    }
    
    func test_viewController_doesNotAlterCurrentRenderingStateOnLoadingError() {
        let stargazer0 = uniqueStargazer()
        let (sut, spy) = makeSUT()
        sut.loadViewIfNeeded()
        spy.completeLoading(with: [stargazer0], at: 0)
        
        sut.simulatePullToRefresh()
        spy.completeLoadingWithError(at: 1)
        
        assertThat(sut, hasRendered: [stargazer0])
    }
    
    func test_stargazerImageView_loadsUserImageURLWhenVisible() {
        let stargazer0 = makeStargazer(
            avatarURL: URL(string: "http://avatar0-image.com")!)
        let (sut, spy) = makeSUT()
        sut.loadViewIfNeeded()
        spy.completeLoading(with: [stargazer0], at: 0)
        
        XCTAssertEqual(spy.loadedImageURLs, [], "Expected no image URL requests until view become visible")
        
        sut.simulateStargazerViewVisible(at: 0)
        
        XCTAssertEqual(spy.loadedImageURLs, [stargazer0.avatarURL], "Expected no image URL requests until view become visible")
    }
    
    // MARK: Utils
    
    private func makeSUT(
        for repository: Repository? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (StargazersViewController, LoaderSpy) {
        let repository = repository ?? anyRepository()
        let spy = LoaderSpy()
        let sut = StargazersViewController(loader: spy, imageLoader: spy, repository: repository)
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
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let stargazerCell = sut.stargazerViewAt(index) as? StargazerCell
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
        
        func completeLoading(with stargazers: [Stargazer] = [], at index: Int = 0) {
            stargazersRequests[index].completion(.success(stargazers))
        }
        
        func completeLoadingWithError(at index: Int = 0) {
            stargazersRequests[index].completion(.failure(anyNSError()))
        }
        
        func repositoryForLoad(at index: Int = 0) -> Repository {
            return stargazersRequests[index].repository
        }
        
        // MARK: - Image Loader
        
        var loadedImageURLs: [URL] = []
        
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
    }
    
}

private extension StargazersViewController {
    func simulatePullToRefresh() {
        let action = refreshControl?.actions(forTarget: self, forControlEvent: .valueChanged)?.first ?? ""
        self.performSelector(onMainThread: Selector(action), with: nil, waitUntilDone: true)
    }
    
    var loadingIndicatorEnabled: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    @discardableResult
    func stargazerViewAt(_ position: Int) -> UIView? {
        let indexPath = IndexPath(row: position, section: stargazersSection)
        return tableView.dataSource?.tableView(
            tableView,
            cellForRowAt: indexPath
        )
    }
    
    func simulateStargazerViewVisible(at index: Int) {
        stargazerViewAt(0)
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
}

