//
//  StargazersLoader.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import Foundation

protocol StargazersLoader {
    func load(completion: (Result<[Stargazer], Error>) -> Void)
}
