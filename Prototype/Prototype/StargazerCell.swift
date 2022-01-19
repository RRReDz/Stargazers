//
//  StargazerCell.swift
//  Prototype
//
//  Created by Riccardo Rossi - Home on 19/01/22.
//

import UIKit

class StargazerCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    func config(with viewModel: StargazerViewModel) {
        self.userImage.image = UIImage(named: viewModel.imageName)
        self.username.text = viewModel.username
    }
}
