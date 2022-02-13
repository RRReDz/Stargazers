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
        fallbackUserImage: UIImage?
    ) -> StargazersViewController {
        let loadViewModel = StargazersLoadViewModel(loader: loader, repository: repository)
        let refreshController = StargazersRefreshController(viewModel: loadViewModel)
        let stargazersController = StargazersViewController(refreshController: refreshController)
        loadViewModel.onStargazersLoad = adaptModelToCellControllers(
            for: stargazersController,
            imageLoader: imageLoader,
            fallbackUserImage: fallbackUserImage
        )
        return stargazersController
    }
    
    private static func adaptModelToCellControllers(
        for stargazersController: StargazersViewController,
        imageLoader: StargazerImageLoader,
        fallbackUserImage: UIImage?
    ) -> ([Stargazer]) -> Void {
        return { [weak stargazersController] stargazers in
            stargazersController?.tableModel = stargazers.map { stargazer in
                let stargazerViewModel = StargazerViewModel(
                    stargazer: stargazer,
                    imageLoader: imageLoader,
                    userImage: { type -> UIImage? in
                        switch type {
                        case let .retrieved(data):
                            return UIImage(data: data)
                        case .fallback:
                            return fallbackUserImage
                        }
                    }
                )
                
                let cellController = StargazerCellController(
                    username: stargazerViewModel.username,
                    delegate: CellControllerToViewModelAdapter(viewModel: stargazerViewModel))
                
                stargazerViewModel.bind(with: cellController)
                
                return cellController
            }
        }
    }
}

private extension StargazerViewModel where Image == UIImage {
    func bind(with cellController: StargazerCellController) {
        onUserImageLoad = { [weak cellController] image in
            cellController?.onUserImageLoad(image: image)
        }
        onUserImageLoadingStateChange = { [weak cellController] isLoading in
            cellController?.onUserImageLoadingStateChange(isLoading: isLoading)
        }
    }
}

private class CellControllerToViewModelAdapter: StargazerCellControllerDelegate {
    private let viewModel: StargazerViewModel<UIImage>
    weak var cellController: StargazerCellController?
    
    init(viewModel: StargazerViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func loadImage() {
        viewModel.loadImage()
    }
    
    func cancelLoadImage() {
        viewModel.cancelImageLoad()
    }
}
