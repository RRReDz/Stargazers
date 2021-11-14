//
//  CodableStargazersStore.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 14/11/21.
//

import Foundation

public class CodableStargazersStore: StargazersStore {
    private typealias Cache = [CodableHashableRepository: [CodableStargazer]]
    
    private struct CodableHashableRepository: Codable, Hashable {
        private let name: String
        private let owner: String
        
        init(from localRepository: LocalRepository) {
            name = localRepository.name
            owner = localRepository.owner
        }
    }
    
    private struct CodableStargazer: Codable {
        private let id: String
        private let username: String
        private let avatarURL: URL
        private let detailURL: URL
        
        init(_ localStargazer: LocalStargazer) {
            id = localStargazer.id
            username = localStargazer.username
            avatarURL = localStargazer.avatarURL
            detailURL = localStargazer.detailURL
        }
        
        var local: LocalStargazer {
            return LocalStargazer(
                id: id,
                username: username,
                avatarURL: avatarURL,
                detailURL: detailURL)
        }
    }
    
    private let storeURL: URL
    private let queue = DispatchQueue(label: "CodableStargazersStoreQueue", attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(from repository: LocalRepository, completion: @escaping RetrieveCompletion) {
        queue.async { [storeURL] in
            do {
                let cache = try Self.retrieveCache(from: storeURL)
                let key = Cache.Key(from: repository)
                let stargazers = cache[key] ?? []
                completion(.success(stargazers.map { $0.local }))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(
        _ stargazers: [LocalStargazer],
        for repository: LocalRepository,
        completion: @escaping InsertCompletion
    ) {
        queue.async(flags: .barrier) { [storeURL] in
            do {
                var cache = try Self.retrieveCache(from: storeURL)
                let key = Cache.Key(from: repository)
                cache[key] = stargazers.map(Cache.Value.Element.init)
                try JSONEncoder().encode(cache).write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteStargazers(
        for repository: LocalRepository,
        completion: @escaping DeleteCompletion
    ) {
        queue.async(flags: .barrier) { [storeURL] in
            do {
                var cache = try Self.retrieveCache(from: storeURL)
                let key = Cache.Key(from: repository)
                cache[key] = nil
                try JSONEncoder().encode(cache).write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func retrieveCache(from storeURL: URL) throws -> Cache {
        guard let data = try? Data(contentsOf: storeURL) else {
            return [:]
        }
        return try JSONDecoder().decode(Cache.self, from: data)
    }
}
