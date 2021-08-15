//
//  Repository.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 15/08/21.
//

import Foundation

public struct Repository: Equatable {
    public let name: String
    public let owner: String
    
    public init(name: String, owner: String) {
        self.name = name
        self.owner = owner
    }
}
