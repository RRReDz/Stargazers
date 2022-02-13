//
//  StargazersRefreshController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import Stargazers
import UIKit

final class StargazersRefreshController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())
    private let viewModel: StargazersLoadViewModel
    var onRefresh: (([Stargazer]) -> Void)?
    
    init(viewModel: StargazersLoadViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadStargazers()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
            
            if let stargazers = viewModel.stargazers {
                self?.onRefresh?(stargazers)
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
