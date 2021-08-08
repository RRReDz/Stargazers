//
//  Stargazer.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import Foundation

public struct Stargazer: Equatable {
    let id: Int
    let username: String
    let avatarURL: URL
    let detailURL: URL
    
    public init(id: Int, username: String, avatarURL: URL, detailURL: URL) {
        self.id = id
        self.username = username
        self.avatarURL = avatarURL
        self.detailURL = detailURL
    }
}
