//
//  StargazersViewModel+Prototypes.swift
//  Prototype
//
//  Created by Riccardo Rossi - Home on 20/01/22.
//

import Foundation

struct StargazerViewModel {
    let imageName: String
    let username: String
}

extension StargazerViewModel {
    static var prototypes: [StargazerViewModel] {
        return (0..<20).map{
            StargazerViewModel(imageName: "image\($0 % 5)", username: "Username\($0)")
        }
    }
}
