//
//  StargazersLoadViewModel.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import Stargazers
import Foundation

class StargazersLoadViewModel {
    private let loader: StargazersLoader
    private let repository: Repository
    
    init(loader: StargazersLoader, repository: Repository) {
        self.loader = loader
        self.repository = repository
    }
    
    private static let loadingErrorTitle: String = NSLocalizedString(
        "STARGAZERS_LOADING_ERROR_TITLE",
        tableName: "Stargazers",
        bundle: Bundle(for: StargazersLoadViewModel.self),
        comment: "Title string for loading error view")

    var onLoadingStateChanged: Observer<Bool>?
    var onStargazersLoad: Observer<[Stargazer]>?
    var onStargazersLoadFailure: Observer<String>?
    
    func loadStargazers() {
        onLoadingStateChanged?(true)
        loader.load(from: repository) { [weak self] result in
            switch result {
            case let .success(stargazers):
                self?.onStargazersLoad?(stargazers)
            case .failure:
                self?.onStargazersLoadFailure?(Self.loadingErrorTitle)
            }
            self?.onLoadingStateChanged?(false)
        }
    }
}
