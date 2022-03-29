//
//  StargazerCellController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import UIKit

final class StargazerCellController {
    private let viewModel: StargazerViewModel<UIImage>
    
    init(viewModel: StargazerViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> StargazerCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: StargazerCell.reuseIdentifier
        ) as! StargazerCell
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
