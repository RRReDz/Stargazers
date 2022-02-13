//
//  StargazerCellController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import UIKit
import Stargazers

final class StargazerViewModel {
    private let stargazer: Stargazer
    private let imageLoader: StargazerImageLoader
    private var imageLoaderTask: StargazerImageLoaderTask?
    private let fallbackUserImage: UIImage
    
    init(stargazer: Stargazer, imageLoader: StargazerImageLoader, fallbackUserImage: UIImage) {
        self.stargazer = stargazer
        self.imageLoader = imageLoader
        self.fallbackUserImage = fallbackUserImage
    }
    
    var username: String {
        stargazer.username
    }
    
    var onUserImageLoadingStateChange: Observer<Bool>?
    var onUserImageLoad: Observer<UIImage>?
    
    func loadImage() {
        onUserImageLoadingStateChange?(true)
        imageLoaderTask = imageLoader.loadImageData(from: stargazer.avatarURL) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(imageData):
                if let image = UIImage(data: imageData) {
                    self.onUserImageLoad?(image)
                }
            case .failure:
                self.onUserImageLoad?(self.fallbackUserImage)
            }
            
            self.onUserImageLoadingStateChange?(false)
        }
    }
    
    func cancelImageLoad() {
        imageLoaderTask?.cancel()
    }
}

final class StargazerCellController {
    private let viewModel: StargazerViewModel
    
    init(viewModel: StargazerViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> StargazerCell {
        let cell = StargazerCell()
        cell.usernameLabel.text = viewModel.username
        viewModel.onUserImageLoadingStateChange = { [weak cell] isLoading in
            cell?.isUserImageLoading = isLoading
        }
        viewModel.onUserImageLoad = { [weak cell] image in
            cell?.userImageView.image = image
        }
        viewModel.loadImage()
        return cell
    }
    
    func cancelImageLoad() {
        viewModel.cancelImageLoad()
    }
}
