Lets you manage items in your keychain. Encodes and decodes the items as Data, and therefore requires that the types of items being added conform to Codable.

```
let keychainManager: KeychainManager = .standard

keychainManager.accessGroup = <app access_group>

try keychainManager.clear()

let value: SomeCodableType = try keychainManager.value(key: "key")

try keychainManager.save(someValue, key: "key", accessibility: kSecAttrAccessibleAfterFirstUnlock)
```