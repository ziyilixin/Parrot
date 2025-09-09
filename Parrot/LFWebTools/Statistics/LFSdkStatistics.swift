import Foundation
import FBSDKCoreKit
import FBAEMKit
import FBSDKCoreKit_Basics
import AppTrackingTransparency
import Adjust

/// 第三方支付打点

class LFSdkStatistics: NSObject {
    
    static let shared = LFSdkStatistics()
    private(set) var attribution_data: ADJAttribution?
    
    public func initConfig() {
        // 保证每次启动app，只执行一次
        if LFWebData.shared.isNeedInitFB {
            if let fbId = LFWebData.shared.fbId, let fbToken = LFWebData.shared.fbToken{
                LFUserDefaults.setFBId(fbId)
                LFUserDefaults.setFBToken(fbToken)
            }
            
            if let fbId = LFUserDefaults.getFBId(), let fbToken = LFUserDefaults.getFBToken() {
                Settings.shared.appID = fbId
                Settings.shared.clientToken = fbToken
                Settings.shared.appURLSchemeSuffix = fbId
                Settings.shared.isAutoLogAppEventsEnabled = true
            }
            
            AppEvents.shared.flush()
            LFWebData.shared.isNeedInitFB = false
            
            // FaceBook初始化
            ApplicationDelegate.shared.initializeSDK()
            
            // Adjust初始化
            self.initializeAJSDK()
        }
    }
    
    /// 充值打点
    func purchase_record(paidAmount: Double, paidCurrency: String, log_type: PurchaseLogType) {
        switch log_type {
        case .Facebook:
            AppEvents.shared.logEvent(AppEvents.Name(LFGlobalStrings.purchase_success))
            AppEvents.shared.logPurchase(amount: paidAmount, currency: paidCurrency)
            break
        case .Firebase:
            break
        case .AJ:
            let event = ADJEvent(eventToken: LFAppConfig.aj_purchase_token)
            event?.setRevenue(paidAmount, currency: paidCurrency)
            Adjust.trackEvent(event)
            break
        case .AppsFlyer:
            break
        }
    }
    
    /// 原生内购打点
    func iap_purchase_record(paidAmount: Double, paidCurrency: String) {
        AppEvents.shared.logEvent(AppEvents.Name(LFGlobalStrings.purchase_success))
        AppEvents.shared.logPurchase(amount: paidAmount, currency: paidCurrency)
        // AJ
        let event = ADJEvent(eventToken: LFAppConfig.aj_purchase_token)
        event?.setRevenue(paidAmount, currency: paidCurrency)
        Adjust.trackEvent(event)
    }
    
    /// 归因数据打点
    private func hitAscribeRecordy() {
        // 获取通用头信息
        let uuid = LFWebData.shared.uuid
        let userId = LFWebData.shared.userId
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
        let identifier = Bundle.main.bundleIdentifier ?? ""
        let parameters:[String:Any] = [
            StringDecrypt.Decrypt(.pkg): identifier,
            StringDecrypt.Decrypt(.ver):  version,
            StringDecrypt.Decrypt(.deviceId): uuid,
            StringDecrypt.Decrypt(.userId): userId,
            StringDecrypt.Decrypt(.utmSource): utm_source,
            StringDecrypt.Decrypt(.adgroupId): ad_group_id,
            StringDecrypt.Decrypt(.adsetId): adset_id,
            StringDecrypt.Decrypt(.campaignId): campaign_id,
            StringDecrypt.Decrypt(.attributionSdk): attribution_sdk,
            StringDecrypt.Decrypt(.attributionSdkVer): attribution_sdk_ver,
            StringDecrypt.Decrypt(.adset): "",
            StringDecrypt.Decrypt(.afStatus): "",
            StringDecrypt.Decrypt(.agency): "",
            StringDecrypt.Decrypt(.afChannel): "",
            StringDecrypt.Decrypt(.campaign): ""
        ]
        
        Task {
            try await LFAPI.LFLog.hitAscribeRecord(parameters: parameters)
        }
    }
    
    var utm_source: String {
        guard let network_ = self.attribution_data?.network?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return "" }
        return network_
    }
    
    var ad_group_id: String {
        guard let ad_group = self.attribution_data?.adgroup?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return "" }
        return ad_group
    }
    
    var adset_id: String {
        guard let creative_ = self.attribution_data?.creative?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return "" }
        return creative_
    }
    
    var campaign_id: String {
        guard let campaign_ = self.attribution_data?.campaign?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return "" }
        return campaign_
    }
    
    var attribution_sdk_ver: String {
        guard let sdk_version = Adjust.sdkVersion() else { return "" }
        return sdk_version
    }
    
    var attribution_sdk: String {
        let value = LFWebData.shared.configModel?.items.first(where: { $0.name == LFGlobalStrings.key_attribution_sdk })?.data?.lf_toString() ?? ""
//        print("to value attributionSdk = \(value)")
        return value
    }
}

extension LFSdkStatistics {
    /// AJ初始化, 必需登录后再调用
    public func initializeAJSDK() {
        guard !LFAppConfig.aj_token.isEmpty else {
            return
        }
        
        Task {
            if #available(iOS 14, *) {
                _ = await request_tracking_authorization()
                let yourAppToken = LFAppConfig.aj_token
                
                #if DEBUG
                let environment = ADJEnvironmentSandbox
                #else
                let environment = ADJEnvironmentProduction
                #endif
                
                let adjustConfig = ADJConfig(appToken: yourAppToken, environment: environment)
                adjustConfig?.delegate = self
                adjustConfig?.logLevel = ADJLogLevelVerbose
                adjustConfig?.sendInBackground = true
                Adjust.appDidLaunch(adjustConfig)
                                
                if let attribution_ = Adjust.attribution() {
                    self.attribution_data = attribution_
                    hitAscribeRecordy()
                }
                
                NotificationCenter.default.removeObserver(self)
                
                NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
                
                didBecomeActive()
            }
        }
    }
    
    @available(iOS 14, *)
    private func request_tracking_authorization() async -> ATTrackingManager.AuthorizationStatus {
        
        return await withUnsafeContinuation { continuation in
            DispatchQueue.main.async {
                Adjust.requestTrackingAuthorization { status in
                    let authorizationStatus = ATTrackingManager.AuthorizationStatus.init(rawValue: status) ?? .denied
                    continuation.resume(returning: authorizationStatus)
                }
            }
        }
    }
    
    @objc private func didBecomeActive() {
        Adjust.trackSubsessionStart()
    }
    
    @objc private func willResignActive() {
        Adjust.trackSubsessionEnd()
    }
}

// MARK: - AdjustDelegate ----------------------------
extension LFSdkStatistics: AdjustDelegate {
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        guard let newAttribution = attribution else { return }
        self.attribution_data = newAttribution
        hitAscribeRecordy()
    }
    
    func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?) {
    }
    
    func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?) {
    }
    
    func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: ADJSessionSuccess?) {
    }
    
    func adjustSessionTrackingFailed(_ sessionFailureResponseData: ADJSessionFailure?) {
    }
}

enum PurchaseLogType: String {
    case Facebook, Firebase, AJ, AppsFlyer
}
