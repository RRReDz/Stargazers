//
//  XCTestCase+MemoryLeaksTracking.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 10/08/21.
//

import Foundation
import XCTest

extension XCTestCase {
    internal func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
