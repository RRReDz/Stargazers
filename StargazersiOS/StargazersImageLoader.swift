//
//  StargazersImageLoader.swift
//  StargazersiOS
//
//  Created by Riccardo Rossi - Home on 12/02/22.
//

import Foundation

public protocol StargazerImageLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> StargazerImageLoaderTask
}

public protocol StargazerImageLoaderTask {
    func cancel()
}
