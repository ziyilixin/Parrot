//
//  UserRepository.swift
//  WebTest
//
//  Created by dayu on 2025/5/27.
//

import Foundation

@objc public class UserRepository:NSObject {
    /* 获取显示策略接口 */
    @objc public static func getConfigAndStrategyInfo(comletion:((_ isReviewPkg: Bool, _ isLogin:Bool) -> Void)?,onFailed:@escaping (() -> Void)) {
        LFWebData.shared.getConfigAndStrategy(onCompletion: comletion,onFailed: onFailed)
    }
    
    /* 登录接口 */
    @objc public static func loginOauth(oauthType:String,token:String,comletion:((Bool) -> Void)?,onFailed:@escaping (() -> Void)) async{
        LFWebData.shared.login(oauthType: oauthType, token: token, completion: comletion,onFailed: onFailed)
    }
    /* 退出接口 */
    @objc public static func logout(completion:((Bool) -> Void)?) async{
        guard let isLogoutSuccee = try? await LFAPI.logout() else {
            completion?(false)
            return
        }
        LFWebData.shared.clear_data()
        completion?(isLogoutSuccee)
    }
    /* 账号删除接口 */
    @objc public static func deleteAccount(completion:((Bool) -> Void)?) async{
        guard let isDeleted = try? await LFAPI.UserInfo.deleteAccount() else {
            completion?(false)
            return
        }
        LFWebData.shared.clear_data()
        completion?(isDeleted)
    }
    /* 获取账号金币接口 */
    @objc public static func getUserCoins(completion:((Int,Bool) ->Void)?) async{
        guard let userInfo = try? await LFAPI.UserInfo.getUser(userId: LFWebData.shared.userId ?? "") else {
            completion?(0,false)
            return
        }
        completion?(userInfo.availableCoins ?? 0,true)
    }
}
