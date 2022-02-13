//
//  StargazersViewController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 04/02/22.
//

import UIKit
import Stargazers

public class StargazersViewController: UITableViewController {
    private let refreshController: StargazersRefreshController
    private let imageLoader: StargazerImageLoader
    private var tableModel = [Stargazer]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var activeTasks: [IndexPath: StargazerImageLoaderTask] = [:]
    private var fallbackUserImage: UIImage
    
    public init(
        loader: StargazersLoader,
        imageLoader: StargazerImageLoader,
        repository: Repository,
        fallbackUserImage: UIImage
    ) {
        self.refreshController = StargazersRefreshController(loader: loader, repository: repository)
        self.imageLoader = imageLoader
        self.fallbackUserImage = fallbackUserImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController.view
        refreshController.onRefresh = { [weak self] stargazers in
            self?.tableModel = stargazers
        }
        refreshController.refresh()
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
        let model = tableModel[indexPath.row]
        let cell = StargazerCell()
        cell.usernameLabel.text = model.username
        cell.isUserImageLoading = true
        let task = imageLoader.loadImageData(from: model.avatarURL) { [unowned self] result in
            let imageData = try? result.get()
            cell.userImageView.image = imageData.map(UIImage.init) ?? self.fallbackUserImage
            cell.isUserImageLoading = false
        }
        activeTasks[indexPath] = task
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        activeTasks[indexPath]?.cancel()
        activeTasks[indexPath] = nil
    }
}
