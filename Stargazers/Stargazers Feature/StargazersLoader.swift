//
//  StargazersLoader.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import Foundation

public protocol StargazersLoader {
    typealias Result = Swift.Result<[Stargazer], Error>
    
    func load(from repository: Repository, completion: @escaping (Result) -> Void)
}

public struct Repository: Equatable {
    public let name: String
    public let owner: String
    
    public init(name: String, owner: String) {
        self.name = name
        self.owner = owner
    }
}
