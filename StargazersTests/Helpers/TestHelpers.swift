//
//  TestHelpers.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 15/08/21.
//

import Foundation
import Stargazers

internal func anyRepository() -> Repository {
    Repository(
        name: "any repository name",
        owner: "any repository owner")
}

internal func anyStargazer() -> Stargazer {
    Stargazer(
        id: "any id",
        username: "any username",
        avatarURL: anyURL(),
        detailURL: anyURL())
}

internal func anyNSError() -> NSError {
    NSError(domain: "any error", code: -1)
}

internal func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}
