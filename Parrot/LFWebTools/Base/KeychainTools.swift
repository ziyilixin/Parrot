import Foundation

class KeychainTools {
    static let uuidKey = "\(Bundle.main.bundleIdentifier ?? "UnknownBundleID")_UUID"
    static func createUUId(_ len: Int = 32) -> String {
        let chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        let tag = (0..<len).reduce("") { acc, _ -> String in
            let randIndex = Int(arc4random_uniform(UInt32(chars.count)))
            return acc + String(chars[randIndex])
        }
        return tag
    }
    
    /// 获取UUID
    /// - Returns: 保存在钥匙串中的UUID（若不存在则生成并存储）
    static func getUUID() -> String {
        if let old: String = LFUserDefaults.getUUID(), !old.isEmpty {
            return old
        }
        
        if let existingUUID = loadUUIDFromKeychain(), !existingUUID.isEmpty {
            return existingUUID
        }
        
        let newUUID = UUID().uuidString
        saveUUIDToKeychain(uuid: newUUID)
        return newUUID
        
    }
    
    /// 从钥匙串加载UUID
    /// - Returns: 保存的UUID，如果没有则返回nil
    private static func loadUUIDFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: uuidKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data, let uuid = String(data: data, encoding: .utf8), !uuid.isEmpty {
            return uuid
        }
        
        return nil
    }
    
    /// 保存UUID到钥匙串
    /// - Parameter uuid: 要保存的UUID字符串
    private static func saveUUIDToKeychain(uuid: String) {
        guard !uuid.isEmpty else { return }
        
        if let existingUUID = loadUUIDFromKeychain(), existingUUID == uuid {
            return
        }
        
        let data = uuid.data(using: .utf8)!
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: uuidKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        SecItemDelete(addQuery as CFDictionary) // 确保唯一性
        SecItemAdd(addQuery as CFDictionary, nil)
    }
}
