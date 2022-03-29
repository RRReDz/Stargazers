//
//  UITableView+Reusable.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi Home on 30/03/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: ReusableTableViewCell>() -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier) as! T
    }
    
    func registerReusableCell<T: ReusableTableViewCell>(_ reusableCellType: T.Type) {
        self.register(
            reusableCellType,
            forCellReuseIdentifier: reusableCellType.reuseIdentifier
        )
    }
}
