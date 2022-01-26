//
//  StargazerCell.swift
//  Prototype
//
//  Created by Riccardo Rossi - Home on 19/01/22.
//

import UIKit

class StargazerCell: UITableViewCell {
    @IBOutlet private(set) weak var userImage: UIImageView!
    @IBOutlet private(set) weak var userImageContainer: UIView!
    @IBOutlet private(set) weak var username: UILabel!
    
    func config(with viewModel: StargazerViewModel) {
        self.userImage.image = UIImage(named: viewModel.imageName)
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: [],
            animations: {
                self.userImage.alpha = 1
            }, completion: { completed in
                if completed {
                    self.userImageContainer.stopShimmering()
                }
            })
        
        self.username.text = viewModel.username
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.alpha = 0
        userImageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImage.alpha = 0
        userImageContainer.startShimmering()
    }
}

private extension UIView {
    private var shimmerAnimationKey: String {
        return "shimmer"
    }

    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height

        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient

        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }

    func stopShimmering() {
        layer.mask = nil
    }
}
