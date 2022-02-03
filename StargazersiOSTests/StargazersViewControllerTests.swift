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
    
    init(loader: StargazersLoader) {
        self.loader = loader
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
        let repository = Repository(name: "Any name", owner: "Any owner")
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
    }
    
    // MARK: Utils
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (StargazersViewController, LoaderSpy) {
        let spy = LoaderSpy()
        let sut = StargazersViewController(loader: spy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
    
    private class LoaderSpy: StargazersLoader {
        var loadCallCount: Int = 0
        private var messages = [(StargazersLoader.Result) -> Void]()
        
        func load(from repository: Repository, completion: @escaping (StargazersLoader.Result) -> Void) {
            loadCallCount += 1
            messages.append(completion)
        }
        
        func completeLoading(at index: Int = 0) {
            messages[index](.success([]))
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
