//
//  StargazersViewController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 04/02/22.
//

import UIKit

public class StargazersViewController: UITableViewController {
    private let refreshController: StargazersRefreshController
    var tableModel = [StargazerCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(refreshController: StargazersRefreshController) {
        self.refreshController = refreshController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController.view
        refreshController.refresh()
        tableView.register(StargazerCell.self, forCellReuseIdentifier: StargazerCell.reuseIdentifier)
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
