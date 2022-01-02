//
//  TestHelpers.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 15/08/21.
//

import Foundation
import Stargazers

internal func anyRepository() -> Repository {
    Repository(name: "any repository name", owner: "any repository owner")
}

internal func uniqueStargazers() -> [Stargazer] {
    let uniqueStargazer = {
        Stargazer(
            id: UUID().uuidString,
            username: "any username",
            avatarURL: anyURL(),
            detailURL: anyURL()
        )
    }
    
    return [
        uniqueStargazer(),
        uniqueStargazer()
    ]
}

internal func anyNSError() -> NSError {
    NSError(domain: "any error", code: -1)
}

internal func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}
