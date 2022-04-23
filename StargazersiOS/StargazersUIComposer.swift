//
//  StargazersUIComposer.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import Stargazers
import UIKit

public final class StargazersUIComposer {
    private init() {}
    
    public static func composedWith(
        loader: StargazersLoader,
        imageLoader: StargazerImageLoader,
        repository: Repository
    ) -> StargazersViewController {
        let loadViewModel = StargazersLoadViewModel(
            loader: MainQueueDispatchDecorator(decoratee: loader),
            repository: repository
        )
        let refreshController = StargazersRefreshController(viewModel: loadViewModel)
        let stargazersController = StargazersViewController(refreshController: refreshController)
        loadViewModel.onStargazersLoad = adaptModelToCellControllers(
            for: stargazersController,
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)
        )
        return stargazersController
    }
    
    private static func adaptModelToCellControllers(
        for stargazersController: StargazersViewController,
        imageLoader: StargazerImageLoader
    ) -> ([Stargazer]) -> Void {
        return { [weak stargazersController] stargazers in
            stargazersController?.tableModel = stargazers.map { stargazer in
                let stargazerViewModel = StargazerViewModel(
                    stargazer: stargazer,
                    imageLoader: imageLoader,
                    imageConverter: UIImage.init
                )
                return StargazerCellController(viewModel: stargazerViewModel)
            }
        }
    }
}

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatchOnMainQueueIfNeeded<T>(result: T, completion: @escaping (T) -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion(result) }
        }
        
        completion(result)
    }
}

extension MainQueueDispatchDecorator: StargazersLoader where T == StargazersLoader {
    func load(from repository: Repository, completion: @escaping (StargazersLoader.Result) -> Void) {
        decoratee.load(from: repository) { [weak self] result in
            self?.dispatchOnMainQueueIfNeeded(
                result: result,
                completion: completion
            )
        }
    }
}

extension MainQueueDispatchDecorator: StargazerImageLoader where T == StargazerImageLoader {
    func loadImageData(from url: URL, completion: @escaping (StargazerImageLoader.Result) -> Void) -> StargazerImageLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatchOnMainQueueIfNeeded(
                result: result,
                completion: completion
            )
        }
    }
}
