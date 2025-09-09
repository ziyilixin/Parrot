//
//  AESCrypto.swift
//  JiemiTest
//
//  Created by dayu on 2025/7/3.
//

import Foundation
import CommonCrypto

class AESCrypto {
    static func decrypt(base64Cipher: String, key: String, iv: String) -> String? {
        guard let data = Data(base64Encoded: base64Cipher),
              let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            return nil
        }

        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesDecrypted: size_t = 0

        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            data.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, kCCKeySizeAES128,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            bufferBytes.baseAddress, bufferSize,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }

        if cryptStatus == kCCSuccess {
            buffer.count = numBytesDecrypted
            return String(data: buffer, encoding: .utf8)
        } else {
            return nil
        }
    }
}
