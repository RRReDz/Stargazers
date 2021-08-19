//
//  Stargazer.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import Foundation

public struct Stargazer: Equatable {
    public let id: String
    public let username: String
    public let avatarURL: URL
    public let detailURL: URL
    
    public init(id: String, username: String, avatarURL: URL, detailURL: URL) {
        self.id = id
        self.username = username
        self.avatarURL = avatarURL
        self.detailURL = detailURL
    }
}
