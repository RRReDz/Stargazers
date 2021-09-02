//
//  HTTPURLResponse+StatusCode.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }
    
    internal var isOK: Bool { statusCode == HTTPURLResponse.OK_200 }
}
