//
//  StargazerCellController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import UIKit

final class StargazerCellController {
    private let viewModel: StargazerViewModel<UIImage>
    private var cell: StargazerCell?
    
    init(viewModel: StargazerViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> StargazerCell {
        cell = tableView.dequeueReusableCell()
        cell?.usernameLabel.text = viewModel.username
        viewModel.onUserImageLoadingStateChange = { [weak self] isLoading in
            self?.cell?.isUserImageLoading = isLoading
        }
        viewModel.onUserImageLoad = { [weak self] image in
            self?.cell?.userImageView.image = image
        }
        viewModel.loadImage()
        return cell!
    }
    
    func cancelImageLoad() {
        cell = nil
        viewModel.cancelImageLoad()
    }
}
