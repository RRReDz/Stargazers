//
//  StargazersRefreshController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import UIKit

final class StargazersRefreshController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())
    private let viewModel: StargazersLoadViewModel
    
    init(viewModel: StargazersLoadViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadStargazers()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChanged = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
