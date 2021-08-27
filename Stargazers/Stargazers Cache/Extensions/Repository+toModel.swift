//
//  Repository+toModel.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

extension Repository {
    var toLocal: LocalRepository {
        LocalRepository(
            name: name,
            owner: owner)
    }
}
