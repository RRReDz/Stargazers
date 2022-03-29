//
//  StargazerCell.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 05/02/22.
//

import UIKit

public class StargazerCell: UITableViewCell {
    public let usernameLabel = UILabel()
    public var isUserImageLoading: Bool = false
    public let userImageView = UIImageView()
    
    static let reuseIdentifier: String = "StargazerCell"
}
