//
//  StargazersRefreshController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import Stargazers
import UIKit

public final class StargazersRefreshController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    private let loader: StargazersLoader
    private let repository: Repository
    
    var onRefresh: (([Stargazer]) -> Void)?
    
    init(loader: StargazersLoader, repository: Repository) {
        self.loader = loader
        self.repository = repository
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        loader.load(from: repository) { [weak self] result in
            if let stargazers = try? result.get() {
                self?.onRefresh?(stargazers)
            }
            self?.view.endRefreshing()
        }
    }
}
