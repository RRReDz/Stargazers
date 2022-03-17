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
    private let imageConverter: (Data) -> Image?
    
    init(stargazer: Stargazer, imageLoader: StargazerImageLoader, imageConverter: @escaping (Data) -> Image?) {
        self.stargazer = stargazer
        self.imageLoader = imageLoader
        self.imageConverter = imageConverter
    }
    
    var username: String {
        stargazer.username
    }
    
    var onUserImageLoadingStateChange: Observer<Bool>?
    var onUserImageLoad: Observer<Image>?
    
    func loadImage() {
        onUserImageLoadingStateChange?(true)
        imageLoaderTask = imageLoader.loadImageData(from: stargazer.avatarURL) { [weak self] result in
            guard let self = self else { return }
            
            if let image = (try? result.get()).flatMap(self.imageConverter) {
                self.onUserImageLoad?(image)
            }
            
            self.onUserImageLoadingStateChange?(false)
        }
    }
    
    func cancelImageLoad() {
        imageLoaderTask?.cancel()
    }
}
