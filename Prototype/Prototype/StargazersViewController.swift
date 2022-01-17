//
//  StargazersViewController.swift
//  Prototype
//
//  Created by Riccardo Rossi - Home on 16/01/22.
//

import UIKit

class StargazersViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "StargazerCellWithImage", for: indexPath)
    }
    
}
