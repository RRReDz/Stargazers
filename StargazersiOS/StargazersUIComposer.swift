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
        let loadViewModel = StargazersLoadViewModel(loader: loader, repository: repository)
        let refreshController = StargazersRefreshController(viewModel: loadViewModel)
        let stargazersController = StargazersViewController(refreshController: refreshController)
        loadViewModel.onStargazersLoad = adaptModelToCellControllers(
            for: stargazersController,
            imageLoader: imageLoader
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
