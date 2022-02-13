//
//  StargazerCellController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import UIKit
import Stargazers

final class StargazerViewModel<Image> {
    private let stargazer: Stargazer
    private let imageLoader: StargazerImageLoader
    private var imageLoaderTask: StargazerImageLoaderTask?
    private let userImage: (UserImage) -> Image?
    
    init(stargazer: Stargazer, imageLoader: StargazerImageLoader, userImage: @escaping (UserImage) -> Image) {
        self.stargazer = stargazer
        self.imageLoader = imageLoader
        self.userImage = userImage
    }
    
    var username: String {
        stargazer.username
    }
    
    var onUserImageLoadingStateChange: Observer<Bool>?
    var onUserImageLoad: Observer<Image>?
    
    enum UserImage {
        case retrieved(Data)
        case fallback
    }
    
    func loadImage() {
        onUserImageLoadingStateChange?(true)
        imageLoaderTask = imageLoader.loadImageData(from: stargazer.avatarURL) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(imageData):
                self.onUserImageLoad?(self.userImage(.retrieved(imageData))!)
            case .failure:
                self.onUserImageLoad?(self.userImage(.fallback)!)
            }
            
            self.onUserImageLoadingStateChange?(false)
        }
    }
    
    func cancelImageLoad() {
        imageLoaderTask?.cancel()
    }
}

final class StargazerCellController {
    private let viewModel: StargazerViewModel<UIImage?>
    
    init(viewModel: StargazerViewModel<UIImage?>) {
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
