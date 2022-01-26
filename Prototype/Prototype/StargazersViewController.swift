//
//  StargazersViewController.swift
//  Prototype
//
//  Created by Riccardo Rossi - Home on 16/01/22.
//

import UIKit

class StargazersViewController: UITableViewController {
    private var stargazers = [StargazerViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.stargazers.isEmpty {
                self.stargazers = StargazerViewModel.prototypes
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }

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
