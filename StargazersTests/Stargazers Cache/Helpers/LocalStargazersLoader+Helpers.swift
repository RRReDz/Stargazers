//
//  LocalStargazersLoader+Helpers.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 31/08/21.
//

import Stargazers

extension LocalStargazersLoader {
    var toWeak: WeakRefProxy<LocalStargazersLoader> { .init(self) }
}
