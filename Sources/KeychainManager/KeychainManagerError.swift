//
//  KeychainManagerError.swift
//
//
//  Created by Fritz Ammon on 4/24/24.
//

import Foundation

public enum KeychainManagerError: Error {
    case duplicateItem
    case itemNotFound
    case noData
    case deletionFailure(String)
    case unhandledError(status: OSStatus)

    init(_ status: OSStatus) {
        switch status {
        case errSecDuplicateItem:
            self = .duplicateItem
        case errSecItemNotFound:
            self = .itemNotFound
        default:
            self = .unhandledError(status: status)
        }
    }
}
