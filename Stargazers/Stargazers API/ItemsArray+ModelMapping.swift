//
//  ItemsArray+ModelMapping.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

internal extension Array where Element == RemoteStargazersMapper.Item {
    var toModels: [Stargazer] {
        self.map { $0.toModel }
    }
}
