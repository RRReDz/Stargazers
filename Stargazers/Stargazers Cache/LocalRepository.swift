//
//  LocalRepository.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

public struct LocalRepository: Equatable {
    let name: String
    let owner: String
    
    public init(name: String, owner: String) {
        self.name = name
        self.owner = owner
    }
}
