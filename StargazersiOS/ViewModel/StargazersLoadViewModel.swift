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
    
    private static let loadingErrorMessage: String = NSLocalizedString(
        "STARGAZERS_LOADING_ERROR_MESSAGE",
        tableName: "Stargazers",
        bundle: Bundle(for: StargazersLoadViewModel.self),
        comment: "Message string for loading error view")
    
    private static let loadingErrorOkActionTitle: String = NSLocalizedString(
        "STARGAZERS_LOADING_ERROR_OK_ACTION",
        tableName: "Stargazers",
        bundle: Bundle(for: StargazersLoadViewModel.self),
        comment: "Title for confirm button of the error view")

    var onLoadingStateChanged: Observer<Bool>?
    var onStargazersLoad: Observer<[Stargazer]>?
    var onStargazersLoadFailure: Observer<ErrorViewData>?
    
    func loadStargazers() {
        onLoadingStateChanged?(true)
        loader.load(from: repository) { [weak self] result in
            switch result {
            case let .success(stargazers):
                self?.onStargazersLoad?(stargazers)
            case .failure:
                self?.onStargazersLoadFailure?(
                    ErrorViewData(
                        title: Self.loadingErrorTitle,
                        message: Self.loadingErrorMessage,
                        okActionTitle: Self.loadingErrorOkActionTitle
                    )
                )
            }
            self?.onLoadingStateChanged?(false)
        }
    }
}

struct ErrorViewData {
    let title: String
    let message: String
    let okActionTitle: String
}
