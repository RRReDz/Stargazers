//
//  ReusableTableViewCell.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi Home on 30/03/22.
//

import UIKit

protocol ReusableTableViewCell: UITableViewCell {
    static var reuseIdentifier: String { get }
}

extension ReusableTableViewCell {
    static var reuseIdentifier: String { String(describing: Self.self) }
}
