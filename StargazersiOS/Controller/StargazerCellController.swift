//
//  StargazerCellController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import UIKit

protocol StargazerCellControllerDelegate {
    func loadImage()
    func cancelLoadImage()
}

final class StargazerCellController {
    let username: String
    let delegate: StargazerCellControllerDelegate
    let cell = StargazerCell()
    
    init(username: String, delegate: StargazerCellControllerDelegate) {
        self.username = username
        self.delegate = delegate
    }
    
    func view() -> StargazerCell {
        cell.usernameLabel.text = username
        delegate.loadImage()
        return cell
    }
    
    func onUserImageLoadingStateChange(isLoading: Bool) {
        cell.isUserImageLoading = isLoading
    }
    
    func onUserImageLoad(image: UIImage?) {
        cell.userImageView.image = image
    }
    
    func cancelImageLoad() {
        delegate.cancelLoadImage()
    }
}
