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
        repository: Repository,
        fallbackUserImage: UIImage
    ) -> StargazersViewController {
        let refreshController = StargazersRefreshController(loader: loader, repository: repository)
        let stargazersController = StargazersViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak stargazersController] stargazers in
            stargazersController?.tableModel = stargazers.map { stargazer in
                StargazerCellController(
                    stargazer: stargazer,
                    imageLoader: imageLoader,
                    fallbackUserImage: fallbackUserImage
                )
            }
        }
        return stargazersController
    }
}
