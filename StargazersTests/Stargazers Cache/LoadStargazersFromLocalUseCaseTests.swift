//
//  LoadStargazersFromLocalUseCaseTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 15/08/21.
//

import XCTest
import Stargazers

final class LocalStargazersLoader: StargazersLoader {
    private let store: StargazersStore
    
    init(store: StargazersStore) {
        self.store = store
    }
    
    func load(completion: @escaping (StargazersLoader.Result) -> Void) {
        store.retrieve()
    }
}

class StargazersStore {
    enum Message {
        case retrieve
    }
    
    var messages = [Message]()
    
    func retrieve() {
        messages.append(.retrieve)
    }
}

class LoadStargazersFromLocalUseCaseTests: XCTestCase {

    func test_init_doesNotMessageTheStore() {
        let store = StargazersStore()
        _ = LocalStargazersLoader(store: store)
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_sendRetrieveMessageTheStore() {
        let store = StargazersStore()
        let sut = LocalStargazersLoader(store: store)
        
        sut.load { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve])
    }

}
