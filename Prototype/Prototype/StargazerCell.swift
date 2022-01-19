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
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: [],
            animations: {
                self.userImage.alpha = 1
            })
        
        self.username.text = viewModel.username
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImage.alpha = 0
    }
}
