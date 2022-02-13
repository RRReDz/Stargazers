//
//  StargazersViewController.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 04/02/22.
//

import UIKit
import Stargazers

public final class StargazersUIComposer {
    public static func composedWith(
        loader: StargazersLoader,
        imageLoader: StargazerImageLoader,
        repository: Repository,
        fallbackUserImage: UIImage
    ) -> StargazersViewController {
        let refreshController = StargazersRefreshController(loader: loader, repository: repository)
        let stargazersController = StargazersViewController(
            refreshController: refreshController,
            imageLoader: imageLoader,
            fallbackUserImage: fallbackUserImage
        )
        return stargazersController
    }
}

final class StargazersCellController {
    private let stargazer: Stargazer
    private let imageLoader: StargazerImageLoader
    private var imageLoaderTask: StargazerImageLoaderTask?
    private let fallbackUserImage: UIImage
    
    init(stargazer: Stargazer, imageLoader: StargazerImageLoader, fallbackUserImage: UIImage) {
        self.stargazer = stargazer
        self.imageLoader = imageLoader
        self.fallbackUserImage = fallbackUserImage
    }
    
    func view() -> StargazerCell {
        let cell = StargazerCell()
        cell.usernameLabel.text = stargazer.username
        cell.isUserImageLoading = true
        imageLoaderTask = imageLoader.loadImageData(from: stargazer.avatarURL) { [unowned self] result in
            let imageData = try? result.get()
            cell.userImageView.image = imageData.map(UIImage.init) ?? self.fallbackUserImage
            cell.isUserImageLoading = false
        }
        return cell
    }
    
    func cancel() {
        imageLoaderTask?.cancel()
    }
}

public class StargazersViewController: UITableViewController {
    private let refreshController: StargazersRefreshController
    private let imageLoader: StargazerImageLoader
    private var fallbackUserImage: UIImage
    private var tableModel = [StargazersCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    public init(
        refreshController: StargazersRefreshController,
        imageLoader: StargazerImageLoader,
        fallbackUserImage: UIImage
    ) {
        self.refreshController = refreshController
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
            guard let self = self else { return }
            
            self.tableModel = stargazers.map { stargazer in
                StargazersCellController(
                    stargazer: stargazer,
                    imageLoader: self.imageLoader,
                    fallbackUserImage: self.fallbackUserImage
                )
            }
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
        let cellController = tableModel[indexPath.row]
        return cellController.view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellController = tableModel[indexPath.row]
        cellController.cancel()
    }
}
