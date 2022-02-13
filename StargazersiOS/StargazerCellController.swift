//
//  StargazerCellController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import UIKit
import Stargazers

final class StargazerCellController {
    private let stargazer: Stargazer
    private let imageLoader: StargazerImageLoader
    private var imageLoaderTask: StargazerImageLoaderTask?
    private let fallbackUserImage: UIImage
    
    init(stargazer: Stargazer, imageLoader: StargazerImageLoader, fallbackUserImage: UIImage) {
        self.stargazer = stargazer
        self.imageLoader = imageLoader
        self.fallbackUserImage = fallbackUserImage
    }
    
    func view() -> StargazerCell {
        let cell = StargazerCell()
        cell.usernameLabel.text = stargazer.username
        cell.isUserImageLoading = true
        imageLoaderTask = imageLoader.loadImageData(from: stargazer.avatarURL) { [unowned self] result in
            let imageData = try? result.get()
            cell.userImageView.image = imageData.map(UIImage.init) ?? self.fallbackUserImage
            cell.isUserImageLoading = false
        }
        return cell
    }
    
    func cancelImageLoad() {
        imageLoaderTask?.cancel()
    }
}
