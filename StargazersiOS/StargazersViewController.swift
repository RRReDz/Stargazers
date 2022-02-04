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
        loader.load(from: repository) { [weak refreshControl] _ in
            refreshControl?.endRefreshing()
        }
    }
}
