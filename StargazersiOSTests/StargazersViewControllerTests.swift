//
//  StargazersViewControllerTests.swift
//  StargazersiOSTests
//
//  Created by Riccardo Rossi - Home on 26/01/22.
//

import XCTest
import Stargazers

class StargazersViewController: UITableViewController {
    private let loader: StargazersLoader
    private let repository: Repository
    
    init(loader: StargazersLoader, repository: Repository) {
        self.loader = loader
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadStargazers), for: .valueChanged)
        
        loadStargazers()
    }
    
    @objc private func loadStargazers() {
        refreshControl?.beginRefreshing()
        loader.load(from: repository) { [weak refreshControl] _ in
            refreshControl?.endRefreshing()
        }
    }
}

class StargazersViewControllerTests: XCTestCase {

    func test_init_doesNotLoadStargazers() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.loadCallCount, 0)
    }
    
    func test_viewController_loadsStargazersWhenLoaded() {
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(spy.loadCallCount, 1)
    }
    
    func test_viewController_loadsStargazersForSelectedRepository() {
        let selectedRepository = uniqueRepository()
        let (sut, spy) = makeSUT(for: selectedRepository)

        sut.loadViewIfNeeded()

        XCTAssertEqual(spy.repositoryRequestForLoad(), selectedRepository)
    }
    
    func test_viewController_loadsStargazersWhenPullToRefreshRequested() {
        let (sut, spy) = makeSUT()

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
        
        XCTAssertEqual(sut.loadingIndicatorEnabled, true)
        
        spy.completeLoading()
        
        XCTAssertEqual(sut.loadingIndicatorEnabled, false)
        
        sut.simulatePullToRefresh()
        
        XCTAssertEqual(sut.loadingIndicatorEnabled, true)
        
        spy.completeLoading(at: 1)
        
        XCTAssertEqual(sut.loadingIndicatorEnabled, false)
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
        
        func completeLoading(at index: Int = 0) {
            messages[index].completion(.success([]))
        }
        
        func repositoryRequestForLoad(at index: Int = 0) -> Repository {
            return messages[index].repository
        }
    }
    
}

private extension StargazersViewController {
    func simulatePullToRefresh() {
        let action = refreshControl?.actions(forTarget: self, forControlEvent: .valueChanged)?.first ?? ""
        self.performSelector(onMainThread: Selector(action), with: nil, waitUntilDone: true)
    }
    
    var loadingIndicatorEnabled: Bool { self.refreshControl?.isRefreshing ?? false }
}
