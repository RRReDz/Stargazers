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
        XCTAssertEqual(spy.loadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(spy.loadCallCount, 1)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(spy.loadCallCount, 2)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(spy.loadCallCount, 3)
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
    }
    
    func test_viewController_successfullyRendersLoadedStargazers() {
        let stargazer0 = uniqueStargazer()
        let stargazer1 = uniqueStargazer()
        let stargazer2 = uniqueStargazer()
        let stargazer3 = uniqueStargazer()
        let (sut, spy) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.renderedStargazerViews, 0)
        
        spy.completeLoading(with: [stargazer0], at: 0)
        XCTAssertEqual(sut.renderedStargazerViews, 1)
        assertThat(sut, hasViewConfiguredFor: stargazer0, at: 0)
        
        sut.simulatePullToRefresh()
        spy.completeLoading(
            with: [
                stargazer0,
                stargazer1,
                stargazer2,
                stargazer3
            ],
            at: 1
        )
        
        XCTAssertEqual(sut.renderedStargazerViews, 4)
        assertThat(sut, hasViewConfiguredFor: stargazer0, at: 0)
        assertThat(sut, hasViewConfiguredFor: stargazer1, at: 1)
        assertThat(sut, hasViewConfiguredFor: stargazer2, at: 2)
        assertThat(sut, hasViewConfiguredFor: stargazer3, at: 3)
    }
    
    // MARK: Utils
    
    private func makeSUT(
        for repository: Repository? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (StargazersViewController, LoaderSpy) {
        let repository = repository ?? anyRepository()
        let spy = LoaderSpy()
        let sut = StargazersViewController(loader: spy, repository: repository)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
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
    
    private class LoaderSpy: StargazersLoader {
        var loadCallCount: Int {
            return messages.count
        }
        private var messages = [(repository: Repository, completion: (StargazersLoader.Result) -> Void)]()
        
        func load(from repository: Repository, completion: @escaping (StargazersLoader.Result) -> Void) {
            messages.append((repository, completion))
        }
        
        func completeLoading(with stargazers: [Stargazer] = [], at index: Int = 0) {
            messages[index].completion(.success(stargazers))
        }
        
        func repositoryForLoad(at index: Int = 0) -> Repository {
            return messages[index].repository
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
    
    func stargazerViewAt(_ position: Int) -> UIView? {
        let indexPath = IndexPath(row: position, section: stargazersSection)
        return tableView.dataSource?.tableView(
            tableView,
            cellForRowAt: indexPath
        )
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

