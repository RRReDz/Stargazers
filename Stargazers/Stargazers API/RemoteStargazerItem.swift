//
//  RemoteStargazerItem.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 01/09/21.
//

import Foundation

internal struct RemoteStargazerItem: Decodable {
    internal let id: Int
    internal let login: String
    internal let avatar_url: URL
    internal let url: URL
}
