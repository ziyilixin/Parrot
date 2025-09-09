import UIKit
import Alamofire

let APIClient = LFAPIClient.shared

class LFAPIClient: NSObject {
    
    static let shared = LFAPIClient()
    
    public var baseHeaders: [String:String] {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        let region_code = Locale.current.region?.identifier ?? "en"
        let system_language = Locale.current.identifier
        let time_zone = TimeZone.current.identifier
        let system_version = UIDevice.current.systemVersion
        var params = [
            StringDecrypt.Decrypt(.devid):  LFWebData.shared.uuid,
            StringDecrypt.Decrypt(.model): LFPhoneInfo.getHardwareIdentifier() ?? "",
            StringDecrypt.Decrypt(.lang): lang,
            StringDecrypt.Decrypt(.sys_lan): lang,
            StringDecrypt.Decrypt(.Authorization): "Bearer \(LFWebData.shared.token)",
            StringDecrypt.Decrypt(.is_anchor): "false",
            StringDecrypt.Decrypt(.platform): "iOS",
            StringDecrypt.Decrypt(.ver): Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            StringDecrypt.Decrypt(.pkg): Bundle.main.bundleIdentifier ?? "",
            StringDecrypt.Decrypt(.time_zone): time_zone,
            StringDecrypt.Decrypt(.device_lang): lang,
            StringDecrypt.Decrypt(.device_country): region_code,
            StringDecrypt.Decrypt(.platform_ver): system_version,
            StringDecrypt.Decrypt(.system_language): system_language,
            StringDecrypt.Decrypt(.user_id): LFWebData.shared.userId ?? "",
            StringDecrypt.Decrypt(.sec_ver): "0",
        ]
        
        if let rc_area_code = LFWebData.shared.rc_area_code {
            params[StringDecrypt.Decrypt(.rc_type)] = rc_area_code
        }
        
        /// AJ公参
        params[StringDecrypt.Decrypt(.attribution_sdk)] = LFSdkStatistics.shared.attribution_sdk
        params[StringDecrypt.Decrypt(.attribution_sdk_ver)] = LFSdkStatistics.shared.attribution_sdk_ver
        
        /// 添加af归因公共请求头
        let afHeaders:[String:String] = [
            StringDecrypt.Decrypt(.utm_source): LFSdkStatistics.shared.utm_source,
            StringDecrypt.Decrypt(.af_adgroup_id): LFSdkStatistics.shared.ad_group_id,
            StringDecrypt.Decrypt(.af_adset_id): LFSdkStatistics.shared.adset_id,
            StringDecrypt.Decrypt(.campaign_id): LFSdkStatistics.shared.campaign_id,
            StringDecrypt.Decrypt(.af_status): "",
            StringDecrypt.Decrypt(.af_agency): "",
            StringDecrypt.Decrypt(.af_channel): "",
            StringDecrypt.Decrypt(.af_adset): "",
            StringDecrypt.Decrypt(.campaign): ""
        ]
        params.merge(afHeaders) { (current, _) in current }
        
        return params
    }
    
    /// SessionManager
    lazy var session: Session = {
        return Session.default
    }()
    
    /// 取消所有网络请求
    func cancelAllRequests() {
        session.cancelAllRequests()
    }
    
    func post<T: Decodable>(url: String, params: [String: Any]?, responseType: T.Type, isLoc: Bool = false) async -> T? {
        let isConfig = url.contains(LFAPIMap.get_config)
        let enkey = isConfig ? URL(string: url)!.host! : LFWebData.shared.enKey
        do {
            let result = await session.request(request(url: url, params: params, enkey: enkey))
                .serializingData()
                .response
            
            return try handleResult(result, isConfig: isConfig, enkey: enkey, isLoc: isLoc)
        } catch {
            return nil
        }
    }
    
    private func request(url: String, params: [String: Any]?, enkey: String) -> URLRequest {
        var params = params ?? [:]
        params[StringDecrypt.Decrypt(.http_headers)] = baseHeaders
        let body_ = LFAESTool.en(params: params, key: enkey)
        
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body_?.base64EncodedString().data(using: .utf8)
        request.httpMethod = "POST"
        
        return request
    }
    
    private func handleResult<T: Decodable>(_ result: DataResponse<Data, AFError>, isConfig: Bool, enkey: String, isLoc: Bool = false) throws -> T? {
        let notLogins = [10010301, 10010302, 100103, 10010303, 10010304]
        let isBool = T.self == Bool.self
        guard let response_data = result.data else {
            return isBool ? (false as? T) : nil
        }
        var rawJSON = String(data: response_data, encoding: .utf8) ?? ""
        rawJSON = rawJSON.replacingOccurrences(of: "\r\n", with: "")
        
        if T.self == Bool.self {
            if let data = LFAESTool.de(rawJSON, key: enkey) {
                let res = try JSONDecoder().decode(LFResModel<LFNilResModel>.self, from: data)
                if let code = res.code, notLogins.contains(code) {
                    // 取消所有网络请求
                    cancelAllRequests()
                    // token 失效跳转登录
                    LFWebData.shared.clear_data()
                    return false as? T
                }
                return res.code == 0 ? true as? T : false as? T
            }
            return false as? T
        }
        
        var data = response_data
        if let dedata = LFAESTool.de(rawJSON, key: enkey)  {
            data = dedata
        }
        
        if LFWebData.shared.isEnabledLog {
            var rawString = String(data: data, encoding: .utf8) ?? ""
            print("url: \(result.request?.url?.absoluteString ?? "") \nResponse: \(rawString)")
        }
        
        if isLoc {
            return try JSONDecoder().decode(T.self, from: data)
        }
        
        do {
            if isConfig {
                let config = try JSONDecoder().decode(LFResModel<LFConfigEnModel>.self, from: data).data
                guard let key3 = config?.zanuc?.base64(), let key2 = config?.zanub?.base64(), var key4 = config?.zanud?.base64() else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.Kmissing)])
                }
                key4 = key4.replacingOccurrences(of: "\r\n", with: "")
                
                guard let configData = LFAESTool.de(key4, key: "\(key2)\(key3)") else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.Condmis)])
                }
                return try JSONDecoder().decode(LFConfigModel.self, from: configData) as? T
            }
            
            let res = try JSONDecoder().decode(LFResModel<T>.self, from: data)
            guard res.code == 0, let data = res.data else {
                if let code = res.code, notLogins.contains(code) {
                    // 取消所有网络请求
                    cancelAllRequests()
                    // token 失效跳转登录
                    LFWebData.shared.clear_data()
                }
                return nil
            }
            return data
        } catch {
            return nil
        }
    }
}
