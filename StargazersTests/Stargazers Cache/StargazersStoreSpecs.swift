//
//  StargazersStoreSpecs.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 29/11/21.
//

import Foundation

protocol StargazersStoreSpecs {
    func test_retrieve_deliversNoResultsOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmtpyCache()
    func test_retrieve_deliversValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectOnNonEmptyCache()
    func test_insert_toNonEmptyCacheOverridesPreviousData()
    func test_insert_toNonEmptyCacheButOtherRepoDoesNotOverridePreviousRepoData()
    func test_deleteStargazers_cacheStaysEmptyOnEmptyCache()
    func test_deleteStargazers_leavesCacheEmptyOnNonEmptyCache()
    func test_deleteStargazers_doesNotLeaveCacheEmptyForOtherRepositoryNonEmptyData()
    func test_sideEffects_runsSerially()
}

protocol FailableRetrieveStargazersStoreSpecs: StargazersStoreSpecs {
    func test_retrieve_returnsErrorOnInvalidCacheData() throws
    func test_retrieve_hasNoSideEffectsOnInvalidCacheData() throws
}

protocol FailableInsertStargazersStoreSpecs: StargazersStoreSpecs {
    func test_insert_deliversErrorOnStoreURLWithNoWritePermissions() throws
    func test_insert_deliversErrorOnInvalidStoreURL() throws
}

protocol FailableDeleteStargazersStoreTestSpecs: StargazersStoreSpecs {
    func test_deleteStargazers_deliversErrorOnStoreURLWithNoWritePermissions() throws
}

typealias FailableStargazersStoreSpecs =
    FailableRetrieveStargazersStoreSpecs &
    FailableInsertStargazersStoreSpecs &
    FailableDeleteStargazersStoreTestSpecs
