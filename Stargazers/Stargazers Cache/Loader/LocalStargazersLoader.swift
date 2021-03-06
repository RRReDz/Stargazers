//
//  LocalStargazersLoader.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

public final class LocalStargazersLoader {
    private let store: StargazersStore
    
    public init(store: StargazersStore) {
        self.store = store
    }
}

extension LocalStargazersLoader: StargazersLoader {
    public typealias LoadResult = StargazersLoader.Result
    public func load(from repository: Repository, completion: @escaping (LoadResult) -> Void) {
        store.retrieve(from: repository.toLocal) { [weak self] result in
            guard self != nil else { return }
            completion(result.map { stargazers in stargazers.toModel })
        }
    }
}
 
extension LocalStargazersLoader {
    public typealias SaveResult = Result<Void, Error>
    public func save(
        _ stargazers: [Stargazer],
        for repository: Repository,
        completion: @escaping (SaveResult) -> Void
    ) {
        store.deleteStargazers(for: repository.toLocal) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.cache(stargazers.toLocal, for: repository.toLocal, with: completion)
                
            case .failure:
                completion(result)
            }
        }
    }
    
    private func cache(
        _ stargazers: [LocalStargazer],
        for repository: LocalRepository,
        with completion: @escaping (SaveResult) -> Void
    ) {
        store.insert(stargazers, for: repository) { [weak self] in
            guard self != nil else { return }
            completion($0)
        }
    }
}
