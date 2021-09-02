//
//  StargazersArray+toLocal.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

extension Array where Element == Stargazer {
    internal var toLocal: [LocalStargazer] {
        return self.map { $0.toLocal }
    }
}
