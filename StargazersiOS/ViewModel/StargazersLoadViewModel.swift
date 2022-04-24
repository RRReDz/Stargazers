//
//  StargazersLoadViewModel.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import Stargazers

class StargazersLoadViewModel {
    private let loader: StargazersLoader
    private let repository: Repository
    
    init(loader: StargazersLoader, repository: Repository) {
        self.loader = loader
        self.repository = repository
    }

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
                self?.onStargazersLoadFailure?("")
            }
            self?.onLoadingStateChanged?(false)
        }
    }
}
