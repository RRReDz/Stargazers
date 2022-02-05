//
//  StargazersViewController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 04/02/22.
//

import UIKit
import Stargazers

public class StargazersViewController: UITableViewController {
    private let loader: StargazersLoader
    private let repository: Repository
    private var stargazers: [Stargazer] = []
    
    public init(loader: StargazersLoader, repository: Repository) {
        self.loader = loader
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadStargazers), for: .valueChanged)
        
        loadStargazers()
    }
    
    @objc private func loadStargazers() {
        refreshControl?.beginRefreshing()
        loader.load(from: repository) { [unowned self] result in
            if let stargazers = try? result.get() {
                self.stargazers = stargazers
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
}

extension StargazersViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stargazers.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = stargazers[indexPath.row]
        let cell = StargazerCell()
        cell.usernameLabel.text = model.username
        return cell
    }
}
