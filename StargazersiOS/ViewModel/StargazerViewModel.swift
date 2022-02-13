//
//  StargazerViewModel.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 13/02/22.
//

import Stargazers
import Foundation

final class StargazerViewModel<Image> {
    private let stargazer: Stargazer
    private let imageLoader: StargazerImageLoader
    private var imageLoaderTask: StargazerImageLoaderTask?
    private let userImage: (UserImage) -> Image?
    
    init(stargazer: Stargazer, imageLoader: StargazerImageLoader, userImage: @escaping (UserImage) -> Image?) {
        self.stargazer = stargazer
        self.imageLoader = imageLoader
        self.userImage = userImage
    }
    
    var username: String {
        stargazer.username
    }
    
    var onUserImageLoadingStateChange: Observer<Bool>?
    var onUserImageLoad: Observer<Image?>?
    
    enum UserImage {
        case retrieved(Data)
        case fallback
    }
    
    func loadImage() {
        onUserImageLoadingStateChange?(true)
        imageLoaderTask = imageLoader.loadImageData(from: stargazer.avatarURL) { [weak self] result in
            if  let imageData = try? result.get(),
                let image = self?.userImage(.retrieved(imageData)) {
                self?.onUserImageLoad?(image)
            } else {
                self?.onUserImageLoad?(self?.userImage(.fallback))
            }
            
            self?.onUserImageLoadingStateChange?(false)
        }
    }
    
    func cancelImageLoad() {
        imageLoaderTask?.cancel()
    }
}
