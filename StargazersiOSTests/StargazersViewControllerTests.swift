//
//  StargazersViewControllerTests.swift
//  StargazersiOSTests
//
//  Created by Riccardo Rossi - Home on 26/01/22.
//

import XCTest

class StargazersViewController: UIViewController {
    private let loader: LoaderSpy
    
    init(loader: LoaderSpy) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LoaderSpy {
    var loadCallCount: Int = 0
}

class StargazersViewControllerTests: XCTestCase {

    func test_init_doesNotLoadStargazers () {
        let spy = LoaderSpy()
        _ = StargazersViewController(loader: spy)
        
        XCTAssertEqual(spy.loadCallCount, 0)
    }

}
