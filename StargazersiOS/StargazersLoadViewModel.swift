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

    var loadingStateChanged: ((Bool) -> Void)?
    var stargazersStateChanged: (([Stargazer]) -> Void)?
    
    func loadStargazers() {
        loadingStateChanged?(true)
        loader.load(from: repository) { [weak self] result in
            if let stargazers = try? result.get() {
                self?.stargazersStateChanged?(stargazers)
            }
            self?.loadingStateChanged?(false)
        }
    }
}
