//
//  StringDecrypt.swift
//  JiemiTest
//
//  Created by dayu on 2025/7/3.
//

import Foundation

struct StringDecrypt {
    
    // MARK: - 静态缓存
    /// 缓存解密后的字符串数据，避免重复读取文件
    private static var decryptedData: [String: String] = [:]
    /// 缓存域名数据的嵌套字典
    private static var domainData: [String: [String: String]] = [:]
    /// 线程安全锁
    private static let lock = NSLock()
    
    /// 通用的解密和解析JSON数据方法
    private static func loadAndDecryptJsonData<T>(_ jsonStr: String, targetType: T.Type) -> T? {
        let jsonString = AESCrypto.decrypt(base64Cipher: jsonStr, key: EncryptStruct.encryKey, iv: EncryptStruct.ebcryIv)
        
        // 将JSON字符串转换成字典
        guard let jsonData = jsonString?.data(using: .utf8) else {
            return nil
        }
        
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? T {
                return jsonDict
            } else {
                print("⚠️ JSON解析错误：数据格式不正确，期望类型: \(targetType)")
                return nil
            }
        } catch {
            print("⚠️ JSON解析错误：\(error.localizedDescription)")
            return nil
        }
    }
    
    /// 初始化普通字符串数据
    private static func initDecryptedData(_ jsonStr: String) {
        lock.lock()
        defer { lock.unlock() }
        
        // 避免重复解密
        if !decryptedData.isEmpty {
            return
        }
        
        if let data = loadAndDecryptJsonData(jsonStr, targetType: [String: String].self) {
            decryptedData = data
        }
    }
    
    /// 初始化域名数据
    private static func initDomainData(_ jsonStr: String) {
        lock.lock()
        defer { lock.unlock() }
        
        // 避免重复解密
        if !domainData.isEmpty {
            return
        }
        
        if let data = loadAndDecryptJsonData(jsonStr, targetType: [String: [String: String]].self) {
            domainData = data
            #if DEBUG
            print("\n")
            print("testWebUrl===\(String(describing: data["dev_domain"]?["h5_domain"]))")
            print("releaseWebUrl===\(String(describing: data["release_domain"]?["h5_domain"]))")
            print("get_config===\(String(describing: data["release_domain"]?["get_config"]))")
            print("\n")
            #else
            #endif
        }
    }
    
    static func Decrypt(_ key: StringKey) -> String {
        // 处理key
        let relKey: String = key.rawValue
        
        // 先检查缓存字典是否有解密数据
        if decryptedData.isEmpty {
            // 如果字典为空，读取并解密Json文件数据
            initDecryptedData(EncryptString.jsonStr)
        }
        
        // 从缓存字典中获取解密后的字符串
        guard let decryptedString = decryptedData[relKey] else {
            print("⚠️ 未找到key对应的解密字符串: \(relKey)")
            return ""
        }
        
        print("解密字符==:\(decryptedString)")
        return decryptedString
    }
    
    static func domainDecrypt(_ key: StringKey) -> String {
        // 处理key
        let relKey: String = key.rawValue
        
        // 先检查缓存字典是否有解密数据
        if domainData.isEmpty {
            // 如果字典为空，读取并解密Json文件数据
            initDomainData(EncryptString.h5_domain)
        }
        
        let domainKey:String = LFEnvDomain.app_env ? StringKey.release_domain.rawValue  : StringKey.dev_domain.rawValue
        
        // 从嵌套字典中获取对应环境的域名配置
        guard let domains = domainData[domainKey] else {
            print("⚠️ 未找到环境配置: \(domainKey)")
            return ""
        }
        
        // 从域名配置中获取解密后的字符串
        guard let decryptedString = domains[relKey] else {
            print("⚠️ 未找到key对应的解密字符串: \(relKey)")
            return ""
        }
        
        print("域名解密字符==:\(decryptedString)")
        return decryptedString
    }
    
}

