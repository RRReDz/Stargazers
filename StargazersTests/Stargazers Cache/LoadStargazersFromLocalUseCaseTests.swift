//
//  LoadStargazersFromLocalUseCaseTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 15/08/21.
//

import XCTest

final class LocalStargazersLoader {
    private let store: StargazersStore
    
    internal init(store: StargazersStore) {
        self.store = store
    }
}

class StargazersStore {
    enum Message: Equatable {}
    
    var messages = [Message]()
}

class LoadStargazersFromLocalUseCaseTests: XCTestCase {

    func test_init_doesNotMessageTheStore() {
        let store = StargazersStore()
        _ = LocalStargazersLoader(store: store)
        
        XCTAssertEqual(store.messages, [])
    }

}
