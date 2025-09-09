import Foundation
import Alamofire

public struct LFAPI {
    struct Config {
        static func getConfig() async throws -> LFConfigModel? {
            let parameters = [StringDecrypt.Decrypt(.ver): 0]
            return await APIClient.post(url: LFAppDomain.appDomain(LFAPIMap.get_config), params: parameters, responseType: LFConfigModel.self)
        }
        
        static func getStrategy() async throws -> LFStrategyModel? {
            return await APIClient.post(url: LFAppDomain.appDomain(LFAPIMap.getStrategy), params: nil, responseType: LFStrategyModel.self)
        }
        
    }
    public struct LFSecurity {
        static func oauth(oauthType:String,token:String?) async throws -> LFLoginModel? {
//            var parameters: [String: Any] = [
//                "token": (token ?? "").isEmpty ? LFWebData.shared.uuid : (token ?? "") as String,
//                "oauthType": oauthType
//            ]
            
            var parameters: [String: Any] = [
                StringDecrypt.Decrypt(.oauthType): oauthType
            ]

            // 根据oauthType的值设置token
            if oauthType == "4" {
                parameters[StringDecrypt.Decrypt(.token)] = LFWebData.shared.uuid
            } else {
                parameters[StringDecrypt.Decrypt(.token)] = token
            }
            
            if let encryptKey = LFWebData.shared.configModel?.riskControlInfoConfig?.k_factor, let encryptText = try? await LFPhoneInfo.configRiskInfo(encryptKey) as String {
                parameters[StringDecrypt.Decrypt(.info)] = encryptText
            }
            let url = LFAppDomain.appDomain(LFAPIMap.oauth)
            print("🌐 网络请求 - URL: \(url)")
            print("📦 请求参数: \(parameters)")
            return await APIClient.post(url: url, params: parameters, responseType: LFLoginModel.self)
        }
        public static func riskInfoUpload() async -> Bool {
            guard let encryptKey = LFWebData.shared.configModel?.riskControlInfoConfig?.k_factor else {
                return false
            }
            
            guard let encryptText = try? await LFPhoneInfo.configRiskInfo(encryptKey) as String else {
                return false
            }
            
            return await APIClient.post(
                url: LFAPIMap.app_domain(LFAPIMap.risk_info_upload),
                params: [StringDecrypt.Decrypt(.info): encryptText],
                responseType: Bool.self
            ) ?? false
        }
    }
    
   public static func logout() async throws -> Bool {
        return await APIClient.post(url: LFAppDomain.appDomain(LFAPIMap.logout), params: nil, responseType: Bool.self) ?? false
    }
    
    static func isValidToken(token: String) async throws -> Bool {
        let parameters = [StringDecrypt.Decrypt(.token): token] as [String : Any]
        return await APIClient.post(url: LFAppDomain.appDomain(LFAPIMap.isValidToken), params: parameters, responseType: Bool.self) ?? false
    }
    
    public struct UserInfo {
        static func deleteAccount() async throws -> Bool {
            return await APIClient.post(url: LFAppDomain.appDomain(LFAPIMap.deleteAccount), params: nil, responseType: Bool.self) ?? false
        }
        
        static func getUser(userId: String) async throws -> LFUserInfoModel? {
            let parameters: [String: Any] = [StringDecrypt.Decrypt(.userId): userId]
            return await APIClient.post(url: LFAppDomain.appDomain(LFAPIMap.getUser), params: parameters, responseType: LFUserInfoModel.self)
        }
        
        static func getRongcloudToken(_ appKey:String? = nil) async throws -> String? {
            let parameters:[String:Any]? =  {
                if let appKey = appKey {
                    return [StringDecrypt.Decrypt(.appKey) : appKey]
                }else{
                    return nil
                }
            }()
            return await APIClient.post(url: LFAppDomain.appDomain(LFAPIMap.getRongcloudToken), params: parameters, responseType: String.self)
        }
        
        static func saveUserInfo(about: String,
                                 birthday: String,
                                 country: String,
                                 language: String,
                                 nickname: String) async throws -> Bool {
            
            var parameters: Parameters = [:]
            parameters[StringDecrypt.Decrypt(.about)] = about
            parameters[StringDecrypt.Decrypt(.birthday)] = birthday
            parameters[StringDecrypt.Decrypt(.country)] = country
            parameters[StringDecrypt.Decrypt(.language)] = language
            parameters[StringDecrypt.Decrypt(.nickname)] = nickname
            
            return await APIClient.post(url: LFAppDomain.appDomain(LFAPIMap.saveUserInfo), params: parameters, responseType: Bool.self) ?? false
        }
        
    }
    
    struct LFLog {
        static func logLiveChat(parameters: [String: Any]) async throws -> Bool {
            let dict:[String: Any] = [
                StringDecrypt.Decrypt(.list): [parameters]
            ]
            return await APIClient.post(url: LFAPIMap.log_url(LFAPIMap.log_livchat), params: dict, responseType: Bool.self) ?? false
        }
        
        /// 归因数据打点
        @discardableResult
        static func hitAscribeRecord(parameters: [String: Any]) async throws -> Bool {
            return await APIClient.post(url: LFAPIMap.app_domain(LFAPIMap.ascribe_record_reqs), params: parameters, responseType: Bool.self) ?? false
        }
    }
    
    public struct Goods {
        static func searchGoods() async throws -> [LFCoinItem] {
            let parameters: [String: Any] = [
                StringDecrypt.Decrypt(.isIncludeSubscription): false,
                StringDecrypt.Decrypt(.payChannel): "IAP"
            ]
            
            return await APIClient.post(url: LFAPIMap.app_domain(LFAPIMap.search_goods), params: parameters, responseType: [LFCoinItem].self) ?? []
        }
        /// 创建充值订单
        static func createOrderInfo(
            goodsCode:String,
            payChannel:String,
            paySource:String = "",
            invitationId:String = "",
            eventExtData: [String: Any] = [:],
            broadcasterId: String = "",
            scriptId: String = "",
            routerPaths: [String] = []
        ) async throws -> LFResModel<LFOrderInfoModel>? {
            var parameters: [String: Any] = [
                StringDecrypt.Decrypt(.goodsCode): goodsCode,
                StringDecrypt.Decrypt(.payChannel): payChannel,
                StringDecrypt.Decrypt(.entry): paySource,
                StringDecrypt.Decrypt(.source): invitationId
            ]
            if (scriptId.isNotEmpty) {
                parameters[LFGlobalStrings.key_script_id] = scriptId
            }
            
            if (broadcasterId.isNotEmpty) {
                parameters[LFGlobalStrings.key_broadcaster_id] = broadcasterId
            }
            
            if (!eventExtData.isEmpty) {
                parameters[LFGlobalStrings.key_event_ext_data] = eventExtData
            }
            
            if (!routerPaths.isEmpty) {
                parameters[LFGlobalStrings.key_event_path] = routerPaths
            }
            return await APIClient.post(
                url: LFAPIMap.app_domain(LFAPIMap.create_recharge),
                params: parameters,
                responseType: LFResModel<LFOrderInfoModel>.self,
                isLoc: true
            )
        }
        
        /// 独立校验
        static func independentVerify(
            orderNo:String,
            payload:String,
            transactionId:String
        ) async throws -> LFResModel<Bool>? {
            let parameters = [
                StringDecrypt.Decrypt(.orderNo): orderNo,
                StringDecrypt.Decrypt(.payload): payload,
                StringDecrypt.Decrypt(.type): "1",
                StringDecrypt.Decrypt(.transactionId): transactionId
            ]
            return await APIClient.post(url: LFAPIMap.app_domain(LFAPIMap.payment_recharge), params: parameters, responseType: LFResModel<Bool>.self, isLoc: true)
        }
        /// 审核模式app扣减金币
        static func reviewModeConsume(
            path:String,
            outlay:Int,
            source:String
        )async throws -> LFResModel<Bool>? {
            let parameters = [
                StringDecrypt.Decrypt(.outlay):String(outlay),
                StringDecrypt.Decrypt(.source):source
            ]
            return await APIClient.post(url: LFAPIMap.app_domain(path), params: parameters, responseType: LFResModel<Bool>.self, isLoc: true)
        }
    }
}
