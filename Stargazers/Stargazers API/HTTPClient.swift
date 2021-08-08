//
//  HTTPClient.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void)
}
