//
//  Optional+toWeak.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 31/08/21.
//

import Stargazers

extension Optional where Wrapped == LocalStargazersLoader {
    var toWeak: WeakRefProxy<Wrapped> { .init(self) }
}
