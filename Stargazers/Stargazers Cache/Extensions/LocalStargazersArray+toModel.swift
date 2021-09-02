//
//  LocalStargazersArray+toModel.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

extension Array where Element == LocalStargazer {
    internal var toModel: [Stargazer] {
        return self.map { $0.toModel }
    }
}
