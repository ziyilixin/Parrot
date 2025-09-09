import UIKit

class LFUserDefaults: NSObject {

    static let standard = LFUserDefaults()

    /// 设置值 (普通值
    func set_object(_ object: Any, forKey key: AppConst.UserDefaultKey) {
        UserDefaults.standard.set(object, forKey: key.rawValue)
    }
    
    /// 设置Cocoble值
    func set_cocoble_object<T: Codable>(_ object: T, forKey key: AppConst.UserDefaultKey) {
        let data = try? JSONEncoder().encode(object)
        UserDefaults.standard.set(data, forKey: key.rawValue)
    }

    func string_object(forKey key: AppConst.UserDefaultKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    func bool_object(forKey key: AppConst.UserDefaultKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    func array_object(forKey key: AppConst.UserDefaultKey) -> [Any] {
        return UserDefaults.standard.array(forKey: key.rawValue) ?? []
    }
    
    /// 获取值
    func get_object(forKey key: AppConst.UserDefaultKey) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
    
    /// 获取Cocoble值
    func get_object<T: Codable>(forKey key: AppConst.UserDefaultKey, with type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(type.self, from: data)
    }
    
    /// 移除
    func remove_object(forKey key: AppConst.UserDefaultKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    func start_synchronize() {
        UserDefaults.standard.synchronize()
    }
    
    static func setFBId(_ value: String ) {
        UserDefaults.standard.setValue(value, forKey: AppConst.UserDefaultKey.fbId.rawValue)
    }
    static func getFBId() -> String? {
        return UserDefaults.standard.string(forKey: AppConst.UserDefaultKey.fbId.rawValue)
    }
    
    static func setFBToken(_ value: String ) {
        UserDefaults.standard.setValue(value, forKey: AppConst.UserDefaultKey.fbToken.rawValue)
    }
    static func getFBToken() -> String? {
        return UserDefaults.standard.string(forKey: AppConst.UserDefaultKey.fbToken.rawValue)
    }
    
    static func setFBFirst(_ value: Bool ) {
        UserDefaults.standard.setValue(value, forKey: AppConst.UserDefaultKey.fbFirst.rawValue)
    }
    static func getFBFirst() -> Bool {
        return UserDefaults.standard.bool(forKey: AppConst.UserDefaultKey.fbFirst.rawValue)
    }
    
    static func setUUID(_ value: String ) {
        UserDefaults.standard.setValue(value, forKey: AppConst.UserDefaultKey.uuid.rawValue)
    }
    static func getUUID() -> String? {
        return UserDefaults.standard.string(forKey: AppConst.UserDefaultKey.uuid.rawValue)
    }
}


extension LFUserDefaults {
    fileprivate func copyGetPayOrderInfo() -> [String : LFOrderInfoModel] {
        var pay_orders:[String: LFOrderInfoModel] = [:]
        
        if let data = UserDefaults.standard.data(forKey: AppConst.UserDefaultKey.PayOrders.rawValue) {
            do {
                let decoder_ = JSONDecoder()
                let decoded_data = try decoder_.decode([String: LFOrderInfoModel].self, from: data)
                pay_orders = decoded_data
            } catch {
            }
        }
        return pay_orders
    }
    
    func getPayOrderInfo() -> [String: LFOrderInfoModel] {
        return copyGetPayOrderInfo()
    }
    
    fileprivate func copySetPayOrderInfo(_ payOrders: [String : LFOrderInfoModel]) {
        do {
            let encoder_ = JSONEncoder()
            let data = try encoder_.encode(payOrders)
            // 存储Data至UserDefaults
            UserDefaults.standard.set(data, forKey: AppConst.UserDefaultKey.PayOrders.rawValue)
        } catch {
            
        }
    }
    
    func setPayOrderInfo(_ payOrders:[String: LFOrderInfoModel]) {
        copySetPayOrderInfo(payOrders)
    }
}


extension LFUserDefaults {
    /// 删除账号时，清除指定缓存
   func deleteAccountCache() {
       remove_object(forKey: .AutoTranslateSwitch)
       remove_object(forKey: .IsFirstSwitchCamera)
       remove_object(forKey: .PromotionInvitationId)
       remove_object(forKey: .PraiseGuide)
    }
}

struct AppConst {
    enum UserDefaultKey: String {
        case AgreePollcy
        case LoginToken
        case LoginInfo
        case IsFirstSwitchCamera
        case AutoTranslateSwitch
        case PayOrders
        case PromotionInvitationId
        case PraiseGuide
        case RcKey
        case fbId
        case fbToken
        case fbFirst
        case uuid
    }
}
