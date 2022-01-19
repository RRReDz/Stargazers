//
//  StargazersViewController.swift
//  Prototype
//
//  Created by Riccardo Rossi - Home on 16/01/22.
//

import UIKit

class StargazersViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StargazerViewModel.prototypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stargazerViewModel = StargazerViewModel.prototypes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "StargazerCellWithImage",
            for: indexPath
        ) as! StargazerCell
        
        cell.config(with: stargazerViewModel)
        
        return cell
    }
    
}
