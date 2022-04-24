//
//  StargazersViewModel.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi Home on 24/04/22.
//

import Foundation

final class StargazersViewModel {
    static let title: String = NSLocalizedString(
        "STARGAZERS_VIEW_TITLE",
        tableName: "Stargazers",
        bundle: Bundle(for: StargazersViewModel.self),
        comment: "Title for main stargazers screen"
    )
}
