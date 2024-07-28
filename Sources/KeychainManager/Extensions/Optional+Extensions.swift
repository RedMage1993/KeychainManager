//
//  OptionalProtocol.swift
//
//
//  Created by Fritz Ammon on 4/19/24.
//

import Foundation

protocol OptionalProtocol {
    func isSome() -> Bool
    func unwrap() -> Any
}

extension Optional: OptionalProtocol {
    func isSome() -> Bool {
        switch self {
        case .none: return false
        case .some: return true
        }
    }

    func unwrap() -> Any {
        switch self {
        case .none: preconditionFailure("trying to unwrap nil")
        case .some(let unwrapped): return unwrapped
        }
    }
}
