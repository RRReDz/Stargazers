//
//  StargazersViewController.swift
//  Prototype
//
//  Created by Riccardo Rossi - Home on 16/01/22.
//

import UIKit

class StargazersViewController: UITableViewController {
    private let stargazers = StargazerViewModel.prototypes

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stargazers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stargazerViewModel = stargazers[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "StargazerCellWithImage",
            for: indexPath
        ) as! StargazerCell
        
        cell.config(with: stargazerViewModel)
        
        return cell
    }
    
}
