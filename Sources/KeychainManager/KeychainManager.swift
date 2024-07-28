//
//  KeychainManager.swift
//
//
//  Created by Fritz Ammon on 4/19/24.
//

import Foundation

public class KeychainManager {
    public var accessGroup: String?
    let decoder: JSONDecoder
    let encoder: JSONEncoder

    public static let standard = KeychainManager()

    public init(accessGroup: String? = nil, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) {
        self.accessGroup = accessGroup
        self.decoder = decoder
        self.encoder = encoder
    }

    public func value<T: Decodable>(key: String) throws -> T? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        var item: CFTypeRef?

        do {
            try handleResult(SecItemCopyMatching(query as CFDictionary, &item))
        } catch KeychainManagerError.itemNotFound {
            return nil
        }

        guard let data = item as? Data else {
            throw KeychainManagerError.noData
        }

        return try String(data: data, encoding: .utf8) as? T ?? decoder.decode(T.self, from: data)

    }

    public func save<T: Encodable>(_ value: T, key: String, accessibility: CFString) throws {
        guard !(value is OptionalProtocol) || (value as? OptionalProtocol)?.isSome() == true else {
            try delete(key: key)
            return
        }

        let data = try (value as? String)?.data(using: .utf8) ?? encoder.encode(value)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: accessibility
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        query[kSecValueData as String] = data

        try delete(key: key)

        try handleResult(SecItemAdd(query as CFDictionary, nil))
    }

    public func allKeys() throws -> [String] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecReturnPersistentRef as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        var item: CFTypeRef?

        do {
            try handleResult(SecItemCopyMatching(query as CFDictionary, &item))
        } catch KeychainManagerError.itemNotFound {
            return []
        }

        return (item as? [[String: Any]])?
            .compactMap { $0[kSecAttrAccount as String] as? String } ?? []
    }

    public func clear() throws {
        try delete(key: nil)
    }

    public func delete(key: String?) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        if let key {
            query[kSecAttrAccount as String] = key
        }

        do {
            try handleResult(SecItemDelete(query as CFDictionary))
        } catch KeychainManagerError.itemNotFound {
            guard let key, try allKeys().contains(key)
            else { return } // Nothing to clear.

            throw KeychainManagerError.deletionFailure(key)
        }
    }

    private func handleResult(_ result: OSStatus) throws {
        guard result == errSecSuccess else {
            throw KeychainManagerError(result)
        }
    }
}
