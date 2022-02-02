//
//  StargazersViewControllerTests.swift
//  StargazersiOSTests
//
//  Created by Riccardo Rossi - Home on 26/01/22.
//

import XCTest
import Stargazers

class StargazersViewController: UIViewController {
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
        
        let repository = Repository(name: "Any name", owner: "Any owner")
        loader.load(from: repository) { _ in }
    }
}

class LoaderSpy: StargazersLoader {
    var loadCallCount: Int = 0
    
    func load(from repository: Repository, completion: @escaping (StargazersLoader.Result) -> Void) {
        loadCallCount += 1
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
    
    // MARK: Utils
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (StargazersViewController, LoaderSpy) {
        let spy = LoaderSpy()
        let sut = StargazersViewController(loader: spy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
    
}
