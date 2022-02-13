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

    var onLoadingStateChanged: ((Bool) -> Void)?
    var onStargazersLoad: (([Stargazer]) -> Void)?
    
    func loadStargazers() {
        onLoadingStateChanged?(true)
        loader.load(from: repository) { [weak self] result in
            if let stargazers = try? result.get() {
                self?.onStargazersLoad?(stargazers)
            }
            self?.onLoadingStateChanged?(false)
        }
    }
}
