//
//  LocalStargazer.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

public struct LocalStargazer: Equatable {
    let id: String
    let username: String
    let avatarURL: URL
    let detailURL: URL
    
    public init(id: String, username: String, avatarURL: URL, detailURL: URL) {
        self.id = id
        self.username = username
        self.avatarURL = avatarURL
        self.detailURL = detailURL
    }
}
