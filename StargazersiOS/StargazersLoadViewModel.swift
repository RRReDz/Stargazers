//
//  StargazersLoadViewModel.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import Stargazers

class StargazersLoadViewModel {
    private enum State {
        case pending
        case loading
        case loaded([Stargazer])
        case failed
    }
    
    private let loader: StargazersLoader
    private let repository: Repository
    private var state: State = .pending {
        didSet {
            onChange?(self)
        }
    }
    
    init(loader: StargazersLoader, repository: Repository) {
        self.loader = loader
        self.repository = repository
    }
    
    var onChange: ((StargazersLoadViewModel) -> Void)?
    
    var isLoading: Bool {
        switch state {
        case .loading: return true
        default: return false
        }
    }
    
    var stargazers: [Stargazer]? {
        switch state {
        case let .loaded(stargazers):
            return stargazers
        default:
            return nil
        }
    }
    
    func loadStargazers() {
        state = .loading
        loader.load(from: repository) { [weak self] result in
            if let stargazers = try? result.get() {
                self?.state = .loaded(stargazers)
            } else {
                self?.state = .failed
            }
            self?.state = .pending
        }
    }
}
