//
//  Strings+UTF8DataEncoding.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 20/08/21.
//

import Foundation

extension String {
    func toDataUTF8() -> Data? {
        self.data(using: .utf8)
    }
}
