import Foundation
import UIKit

struct EncryptStruct{
   static let encryKey = "3Zk8Qp2Rt7Ds5Fg4"
    static let ebcryIv = "t5B7Vn1xG9cX3jK6"
}

//全局环境变量，false 为测试环境，true为正式环境
public class LFEnvDomain{
    #if DEBUG
    static var app_env: Bool = false
    #else
    static var app_env: Bool = false
    #endif
}

public class LFAppDomain {
    /// app基础域名
    static var app_domain: String {
        "https://\(StringDecrypt.domainDecrypt(.app_domain))"
    }
    /// ws域名
    static var im_domain: String {
        "wss://\(StringDecrypt.domainDecrypt(.im_domain))"
    }
    /// log域名
    static var log_domian: String {
        "https://\(StringDecrypt.domainDecrypt(.log_domian))"
    }
    /// H5域名
    /// 测试域名：https://test-h5.seal-art.com/
    static var h5_domain: String {
        "https://\(StringDecrypt.domainDecrypt(.h5_domain))/"
    }
    /// Web域名
    static var web_domain: String { h5_domain + web_path }
    
    static func appDomain(_ map: String) -> String {
        return LFAppDomain.app_domain + map
    }
    
    static var imDomain: String {
        return LFAppDomain.im_domain
    }

    static func logDomainURL(_ path: String) -> String {
        return LFAppDomain.log_domian + path
    }
}

@objc public class LFAppLink:NSObject {
    /// 隐私政策
    @objc static var privacy_url: String {
        StringDecrypt.domainDecrypt(.privacy_url)
    }
    /// 用户协议
    @objc static var terms_url: String {
         StringDecrypt.domainDecrypt(.terms_url)
    }
    /// App logo，类型可以是http或者base64
    static var app_logo: String { app_logo_base64 }
}

public class LFAppConfig {
    /// appID
    static var app_id: String { "" }
    /// AJ App token
    static var aj_token: String { "" }
    /// AJ 购买 token
    static var aj_purchase_token: String { "" }
}

// 是否是LivChat web
var is_livchat_web: Bool {
    // 1.从Config接口中的app_ext_data获取
    // 2.判断是否是WebType中的一种，参考代码如下
    guard let webType = LFWebData.shared.configModel?.items.first(where: { $0.name == StringDecrypt.Decrypt(.app_ext_data) }),
          let data = webType.data,
          let valueDict = data.value_any as? [String: Any],
          let webConfig = valueDict[StringDecrypt.Decrypt(.webConfig)] as? [String : Any],
          let is_lf_web = webConfig[StringDecrypt.Decrypt(.isWeb)]
    else {
        print("解包失败")
        return false
    }
    // is_lf_web 为0 为livChat，默认为flase, 1 为灵峰，
    return (is_lf_web as? Int ?? 0) ==  0
}

// 路径
var web_path: String {
    // 1.从Config接口中的app_ext_data获取
    // 2.从app_ext_data中取web_config
    // 3.从web_config中取web_path
    // 默认 "br/app/"
    guard let webType = LFWebData.shared.configModel?.items.first(where: { $0.name == StringDecrypt.Decrypt(.app_ext_data) }),
          let data = webType.data,
          let valueDict = data.value_any as? [String: Any],
          let webConfig = valueDict[StringDecrypt.Decrypt(.webConfig)] as? [String : Any],
          let web_path = webConfig[StringDecrypt.Decrypt(.webp)]
    else {
        print("解包失败")
        return StringDecrypt.Decrypt(.br_app)
    }
    return web_path as? String ?? StringDecrypt.Decrypt(.br_app)
}

/// 背景颜色
var web_bg_color: String {
    // 1.从Config接口中的app_ext_data获取
    // 2.从app_ext_data中取web_config
    // 3.从web_config中取bg_color
    // 默认 "#1E1A32"
    guard let webType = LFWebData.shared.configModel?.items.first(where: { $0.name == StringDecrypt.Decrypt(.app_ext_data) }),
          let data = webType.data,
          let valueDict = data.value_any as? [String: Any],
          let webConfig = valueDict[StringDecrypt.Decrypt(.webConfig)] as? [String : Any],
          let bg_color = webConfig[StringDecrypt.Decrypt(.bgColor)]
    else {
        print("解包失败")
        return StringDecrypt.Decrypt(.webDfbgColor)
    }
    return bg_color as? String ?? StringDecrypt.Decrypt(.webDfbgColor)
}

/// 导航栏文字颜色
var web_nav_title_color: String {
    // 1.从Config接口中的app_ext_data获取
    // 2.从app_ext_data中取web_config
    // 3.从web_config中取web_nav_title_color
    // 默认 "#FFFFFF"
    guard let webType = LFWebData.shared.configModel?.items.first(where: { $0.name == StringDecrypt.Decrypt(.app_ext_data) }),
          let data = webType.data,
          let valueDict = data.value_any as? [String: Any],
          let webConfig = valueDict[StringDecrypt.Decrypt(.webConfig)] as? [String : Any],
          let nav_title_color = webConfig[StringDecrypt.Decrypt(.natitleColor)]
    else {
        print("解包失败")
        return StringDecrypt.Decrypt(.white)
    }
    return nav_title_color as? String ?? StringDecrypt.Decrypt(.white)
}

/// 状态栏
var web_status_bar_style: UIStatusBarStyle {
    // 1.从Config接口中的app_ext_data获取
    // 2.从app_ext_data中取web_config
    // 3.从web_config中取status_bar_style（0->.lightContent 1->.darkContent）
    // 默认 ".lightContent"
    guard let webType = LFWebData.shared.configModel?.items.first(where: { $0.name == StringDecrypt.Decrypt(.app_ext_data) }),
          let data = webType.data,
          let valueDict = data.value_any as? [String: Any],
          let webConfig = valueDict[StringDecrypt.Decrypt(.webConfig)] as? [String : Any],
          let status_bar_style = webConfig[StringDecrypt.Decrypt(.sbs)]
    else {
        print("解包失败")
        return .lightContent
    }
    return (status_bar_style as? Int ?? 0) == 1 ? .darkContent : .lightContent
}

#if DEBUG
let is_debug_fl = false
#else
let is_debug_fl = false
#endif

public class LFAPIMap {
    /// App Config接口
    public static var get_config: String {
        "/\(StringDecrypt.domainDecrypt(.get_config))"
    }
    /// 内购商品列表接口
    public static var search_goods: String {
        "/\(StringDecrypt.domainDecrypt(.search_goods))"
    }
    /// 创建内购订单接口
    public static var create_recharge: String {
        "/\(StringDecrypt.domainDecrypt(.create_recharge))"
    }
    /// 内购校验接口
    public static var payment_recharge: String {
        "/\(StringDecrypt.domainDecrypt(.payment_recharge))"
    }
    /// 打点接口
    public static var log_livchat: String {
        "/\(StringDecrypt.domainDecrypt(.log_livchat))"
    }
    /// 风控上报接口
    public static var risk_info_upload: String {
        "/\(StringDecrypt.domainDecrypt(.risk_info_upload))"
    }
    /// 归因上报接口
    public static var ascribe_record_reqs: String {
        "/\(StringDecrypt.domainDecrypt(.ascribe_record_reqs))"
    }
    
    public static var getStrategy: String {
        "/\(StringDecrypt.domainDecrypt(.getStrategy))"
    }
    public static var oauth: String {
        "/\(StringDecrypt.domainDecrypt(.oauth))"
    }
    public static var logout: String {
        "/\(StringDecrypt.domainDecrypt(.logout))"
    }
    public static var isValidToken: String {
        "/\(StringDecrypt.domainDecrypt(.isValidToken))"
    }
    public static var deleteAccount: String {
        "/\(StringDecrypt.domainDecrypt(.deleteAccount))"
    }
    public static var getRongcloudToken: String {
        "/\(StringDecrypt.domainDecrypt(.getRongcloudToken))"
    }
    public static var getUser: String {
        "/\(StringDecrypt.domainDecrypt(.getUser))"
    }
    public static var saveUserInfo : String {
        "/\(StringDecrypt.domainDecrypt(.saveUserInfo))"
    }
    public static var coinsume : String {
        "/\(StringDecrypt.domainDecrypt(.coinsume))"
    }

    static func app_domain(_ map: String) -> String { LFAppDomain.app_domain + map }
    
    static var im_domain: String { LFAppDomain.im_domain }

    static func log_url(_ path: String) -> String { LFAppDomain.log_domian + path }
}

/// App Logo
var app_logo_base64: String {
    if let image_ = UIImage(named: "login_logo"), let image_data = image_.pngData() {
        return "data:image/png;base64," + image_data.base64EncodedString()
    }
    return ""
}
