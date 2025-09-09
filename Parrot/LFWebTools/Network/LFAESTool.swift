import Foundation
import CommonCrypto

enum LFAESTool {
    static func de(_ text: String, key: String) -> Data? {
        guard let data = Data(base64Encoded: text) else { return nil }
        return de(data, key: key)
    }
    
    static func de(_ data: Data, key: String) -> Data? {
        let adjustedKey = handleKey(key)
        
        guard let keyData = adjustedKey.data(using: .utf8)?.fff(kCCKeySizeAES256) else { return nil }
        
        let buffer_size = data.count + kCCBlockSizeAES128
        var buffer_ = Data(count: buffer_size)
        
        var decryptedBytes: size_t = 0
        let status = buffer_.withUnsafeMutableBytes { aBytes in
            data.withUnsafeBytes { cipherBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionECBMode + kCCOptionPKCS7Padding),
                        keyBytes.baseAddress, kCCKeySizeAES256,
                        nil,
                        cipherBytes.baseAddress, data.count,
                        aBytes.baseAddress, buffer_size,
                        &decryptedBytes
                    )
                }
            }
        }
        
        guard status == kCCSuccess else { return nil }
        buffer_.removeSubrange(decryptedBytes..<buffer_.count)
        return buffer_
    }
    
    static func en(params: [String: Any]?, key: String) -> Data? {
        let dataParams = params ?? [:]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dataParams, options: []) else {
            return nil
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return en(jsonString, key: key)
    }
    
    static func en(_ text: String, key: String) -> Data? {
        let adjustedKey = handleKey(key)
        guard let keyData = adjustedKey.data(using: .utf8)?.fff(kCCKeySizeAES256), let data = text.data(using: .utf8)
        else { return nil }
        
        let abuffer_size = data.count + kCCBlockSizeAES128
        var buffer_ = Data(count: abuffer_size)
        
        var aencryptedsBytes: size_t = 0
        let status = buffer_.withUnsafeMutableBytes { aBytes in
            data.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionECBMode + kCCOptionPKCS7Padding),
                        keyBytes.baseAddress, kCCKeySizeAES256,
                        nil,
                        dataBytes.baseAddress, data.count,
                        aBytes.baseAddress, abuffer_size,
                        &aencryptedsBytes
                    )
                }
            }
        }
        
        if (status == kCCSuccess) {
            buffer_.removeSubrange(aencryptedsBytes..<buffer_.count)
            return buffer_
        }
        return nil
    }
    
    static func handleKey(_ key: String, len: Int = 32) -> String {
        if key.count > len {
            return String(key.prefix(len))
        } else {
            return key.padding(toLength: len, withPad: "0", startingAt: 0)
        }
    }
}

extension Data {
    func fff(_ len: Int) -> Data {
        var data = self
        let length_ = len - self.count
        if length_ > 0 {
            data.append(Data(repeating: 0, count: length_))
        }
        return data
    }
}

extension String {
    func base64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// String 转 Model
    /// - Returns: T?
    func lf_to_model<T: Decodable>() -> T? {
        guard let data = self.data(using: .utf8) else {
            print("string -> data, error")
            return nil
        }
        
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            print(error)
            return nil
        }
    }
}
