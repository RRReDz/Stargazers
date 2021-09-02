//
//  WeakRefProxy.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 31/08/21.
//

import Foundation

internal class WeakRefProxy<T: AnyObject> {
    private(set) weak var object: T?
    
    internal init(_ object: T?) {
        self.object = object
    }
}
