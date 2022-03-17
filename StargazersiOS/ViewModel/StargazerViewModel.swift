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
    private let imageDataConverter: (Data) -> Image?
    
    init(stargazer: Stargazer, imageLoader: StargazerImageLoader, imageDataConverter: @escaping (Data) -> Image?) {
        self.stargazer = stargazer
        self.imageLoader = imageLoader
        self.imageDataConverter = imageDataConverter
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
            
            if
                let imageData = try? result.get(),
                let image = self.imageDataConverter(imageData)
            {
                self.onUserImageLoad?(image)
            }
            
            self.onUserImageLoadingStateChange?(false)
        }
    }
    
    func cancelImageLoad() {
        imageLoaderTask?.cancel()
    }
}
