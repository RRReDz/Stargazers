//
//  StargazersViewController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 04/02/22.
//

import UIKit

final class StargazersErrorController {
    private let viewModel: StargazersLoadViewModel
    
    init(viewModel: StargazersLoadViewModel) {
        self.viewModel = viewModel
        viewModel.onStargazersLoadFailure = { [weak self] errorData in
            let alert = UIAlertController()
            alert.title = errorData.title
            alert.message = errorData.message
            alert.addAction(UIAlertAction(title: errorData.okActionTitle, style: .default))
            self?.onErrorView?(alert)
        }
    }
    
    var onErrorView: ((UIAlertController) -> Void)?
}

public class StargazersViewController: UITableViewController {
    private let refreshController: StargazersRefreshController
    private let errorController: StargazersErrorController
    var tableModel = [StargazerCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(
        refreshController: StargazersRefreshController,
        errorController: StargazersErrorController
    ) {
        self.refreshController = refreshController
        self.errorController = errorController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController.view
        refreshController.refresh()
        errorController.onErrorView = { [weak self] errorView in
            self?.present(errorView, animated: true)
        }
        tableView.registerReusableCell(StargazerCell.self)
    }
}

extension StargazersViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(at: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).cancelImageLoad()
    }
    
    private func cellController(at indexPath: IndexPath) -> StargazerCellController {
        return tableModel[indexPath.row]
    }
}
