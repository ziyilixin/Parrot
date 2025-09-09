import Foundation
import UIKit

@objc class LFWebData:NSObject {
    @objc static let shared = LFWebData()
    
    var configModel: LFConfigModel?
    var strategyModel: LFStrategyModel?
    var userModel: LFUserInfoModel?
    @objc var token: String {
        set {
            UserDefaults.standard .set(newValue, forKey: StringDecrypt.Decrypt(.LFWebToken))
        }
        get{
            return UserDefaults.standard.value(forKey: StringDecrypt.Decrypt(.LFWebToken)) as? String ?? ""
        }
    }
    var isNeedInitFB = true
    /// 打印日志
    var isEnabledLog = true
    
    // 传进来的uuid，可以选
    var oldUUID: String = ""
    
    @objc var uuid: String {
        if !oldUUID.isEmpty {
            return oldUUID
        }
        let value = KeychainTools.getUUID()
        oldUUID = value
        // 独立缓存再保存多一份，双保险
        LFUserDefaults.setUUID(value)
        return value
    }
    
    var rc_area_code: String? {
        let value = configModel?.items.filter({ $0.name == StringDecrypt.Decrypt(.rc_area_code) }).first?.data?.lf_toString()
        return value
    }
    
    var fbId: String? {
        let value = configModel?.items.first(where: { $0.name == StringDecrypt.Decrypt(.app_fb_id) })?.data?.lf_toString()
        return value
    }
    
    var fbToken: String? {
        let value = configModel?.items.first(where: { $0.name == StringDecrypt.Decrypt(.app_fb_client_token) })?.data?.lf_toString()
        return value
    }
    
    var enKey: String {
        let value = configModel?.items.first(where: { $0.name == StringDecrypt.Decrypt(.encrypt_key) })?.data?.lf_toString() ?? ""
        return value
    }
    
    @objc var userId: String? {
        set {
            UserDefaults.standard .set(newValue, forKey: StringDecrypt.Decrypt(.LFWeb_useID))
        }
        get{
            return UserDefaults.standard.value(forKey: StringDecrypt.Decrypt(.LFWeb_useID)) as? String ?? ""
        }
    }
    
    /// 初始化H5B框架，仅赋值信息，是否跳转到B面通过isReviewPkg决定
    /// - Parameters:
    ///   - token: 登录token
    ///   - user_uuid: 登录UUID
    ///   - config_data: App配置
    ///   - strategy_data: 策略
    func init_LF_kit(token: String, user_data: String, config_data: String, strategy_data: String) {
        // 赋值App config
        guard let config_info: LFConfigModel = config_data.lf_to_model() else {
            return
        }
        
        LFWebData.shared.configModel = config_info
        
        // 赋值登录信息
        guard let user_info: LFUserInfoModel = user_data.lf_to_model() else {
            return
        }
        LFWebData.shared.token = token
        LFWebData.shared.userModel = user_info
        
        // 赋值策略信息
        guard let strategy_info: LFStrategyModel = strategy_data.lf_to_model() else {
            return
        }
        LFWebData.shared.strategyModel = strategy_info
        
        // 保证每次启动app，只执行一次
        if LFWebData.shared.isNeedInitFB {
            LFSdkStatistics.shared.initConfig()
        }
    }
    
    /// 清空数据（退出登录）
    func clear_data() {
        
        LFWebData.shared.token = ""
        if LFWebData.shared.userModel != nil {
            LFWebData.shared.userModel = nil
        }
        if LFWebData.shared.strategyModel != nil{
            LFWebData.shared.strategyModel = nil
        }
        //
        DispatchQueue.main.async {
            LFRouter.switchRootViewController(LoginViewController())
        }
        
    }
    
    var completion: ((Bool) -> Void)?
    var onCompletion: ((_ isReviewPkg: Bool, _ isLogin:Bool) -> Void)?
    var onFailed: (() -> Void)!
    var oauthType:String = "4"
    @objc public func login(oauthType:String,token:String,completion: ((Bool) -> Void)? = nil,onFailed: @escaping (() -> Void)) {
        self.completion = completion
        self.onFailed = onFailed
        self.oauthType = oauthType
        self.token = token
        self.appConfig()
    }
    
    @objc public func getConfigAndStrategy(onCompletion: ((_ isReviewPkg: Bool, _ isLogin:Bool) -> Void)? = nil,onFailed:@escaping (() -> Void)) {
        self.onCompletion = onCompletion
        self.onFailed = onFailed
        DispatchQueue.main.async {
            //LFLoading.show()
            Task {
                do {
                    guard let configInfo = try await LFAPI.Config.getConfig() else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.configNetErr)])
                    }
                    LFWebData.shared.configModel = configInfo
                    
                    if self.token.isEmpty {
                        //LFLoading.hide()
                        self.onCompletion?(false,false)
                    }else{
                        //获取用户信息
                        guard let userModel = try await LFAPI.UserInfo.getUser(userId: self.userId ?? "") else {
                            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.configNetErr)])
                        }
                        LFWebData.shared.userModel = userModel
                        // 获取策略
                        self.getStrategyInfo()
                    }
                } catch {
                    //LFLoading.hide()
                    self.onFailed()
                }
            }
        }
    }
    
    @objc public func laoding() {
        LFLoading.show()
    }
    @objc public func loadingHidde() {
        LFLoading.hide()
    }
    
    private func appConfig(_ isFirst: Bool = true) {
        DispatchQueue.main.async {
            if isFirst {
                LFLoading.show()
            }
            
            Task {
                do {
                    guard let configInfo = try await LFAPI.Config.getConfig() else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.configNetErr)])
                    }
                    LFWebData.shared.configModel = configInfo
                    
                    guard let loginInfo = try await LFAPI.LFSecurity.oauth(oauthType:self.oauthType , token: self.token) else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.configNetErr)])
                    }
                    LFWebData.shared.token = loginInfo.token ?? ""
                    LFWebData.shared.userId = loginInfo.userInfo?.userId ?? ""
                    LFWebData.shared.userModel = loginInfo.userInfo
                    print("userId = \(loginInfo.userInfo?.userId ?? "")")
                    
                
                    // 获取策略
                    self.getStrategyInfo(isLogin: true)
                    
                } catch {
                    DispatchQueue.main.async { [self] in
                        self.onFailed()
                        LFLoading.hide()
                    }
                }
            }
        }
    }
    
    
    private func getStrategyInfo(isLogin:Bool = false) {
        Task {
            do {
                guard let strategyInfo = try await LFAPI.Config.getStrategy() else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.getStNetError)])
                }
                LFWebData.shared.strategyModel = strategyInfo
                
                // 创建 JSON 编码器
                let encoder = JSONEncoder()
                // 让输出的 JSON 数据带有缩进，提高可读性
                encoder.outputFormatting = .prettyPrinted
                // 进行编码操作
                let userData = try encoder.encode(LFWebData.shared.userModel)
                let configData = try encoder.encode(LFWebData.shared.configModel)
                let strategyData = try encoder.encode(strategyInfo)
                // 将 JSON 数据转换为字符串
                guard let userString = String(data: userData, encoding: .utf8) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.NetwError)])
                }
                guard let configString = String(data: configData, encoding: .utf8) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.NetwError)])
                }
                guard let strategyString = String(data: strategyData, encoding: .utf8) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: StringDecrypt.Decrypt(.NetwError)])
                }
                // 3. 构建Web页面前初始化
                LFWebData.shared.init_LF_kit(token: LFWebData.shared.token, user_data:userString , config_data: configString, strategy_data: strategyString)
                
                LFLoading.hide()
                
                let isReviewPkg = strategyInfo.isReviewPkg ?? true
                self.isNeedInitFB = !isReviewPkg
                
                DispatchQueue.main.async {
                    self.completion?(!self.isNeedInitFB)
                    self.onCompletion?(!self.isNeedInitFB,true)
                    self.shCheckTimer?.invalidate()
                    self.shCheckTimer = nil
                    self.autoCheckSH()
                }
                
            } catch {
                self.onFailed()
                LFLoading.hide()
            }
        }
    }
    
    // Add timer property
    private var shCheckTimer: Timer?
    
    /// 在A面才自动检测是否需要跳转b面
    private func autoCheckSH() {
        DispatchQueue.main.async {
            guard !self.isNeedInitFB else {
                // Clean up timer if we're in B mode
                self.shCheckTimer?.invalidate()
                self.shCheckTimer = nil
                return
            }
            
            // Cancel any existing timer
            self.shCheckTimer?.invalidate()
            self.shCheckTimer = nil
        }
    }
    
    deinit {
        // Clean up timer when object is deallocated
        shCheckTimer?.invalidate()
        shCheckTimer = nil
    }
    
    @objc public class LFRouter: NSObject {
        @objc public static func switchRootViewController(_ viewController: UIViewController) {
            // 获取当前的 UIApplicationDelegate
            if let appDelegate = UIApplication.shared.delegate, let window = appDelegate.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                
                // 使用动画过渡切换根视图控制器
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = viewController
                })
            }
        }
    }
    
}
