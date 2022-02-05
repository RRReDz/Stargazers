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
    
    func test_viewController_numberOfRowsWillBeTheSameAsTheNumberOfStargazers() {
        let stargazers = uniqueStargazers()
        let (sut, spy) = makeSUT()
        sut.loadViewIfNeeded()
        
        spy.completeLoading(with: stargazers)
        
        XCTAssertEqual(
            sut.tableView.numberOfRows(inSection: 0),
            stargazers.count
        )
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
}

