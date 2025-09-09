//
//  UserInfoEntity.swift
//  WebTest
//
//  Created by dayu on 2025/5/26.
//

import Foundation

@objc class UserInfoEntity: NSObject{
    var userId: String?
    var rongcloudToken: String?
    var level: Int?
    var avatarThumbURL: String?
    var country: String?
    var isHavePassword: Bool?
    var nickname: String?
    var isRecharge: Bool?
    var isSwitchNotDisturbIM: Bool?
    var hasEquity: Bool?
    var registerCountry: String?
    var tagsList: [String]?
    var isBlock: Bool?
    var isAnswer: Bool?
    var isInternal: Bool?
    var birthday: String?
    var followNum: Int?
    var auditStatus: Int?
    var avatar: String?
    var avatarUrl: String?
    var loginPkgName: String?
    var avatarMiddleThumbURL: String?
    var isVip: Bool?
    var isSwitchNotDisturbCall: Bool?
    var gender: Int?
    var createTime: Int64?
    var isMultiple: Bool?
    var praiseNum: Int?
    var userType: Int?
    var age: Int?
    var tagDetails: [TagDetail]?
    var isReview: Bool?
    var availableCoins: Int?
    var registerPkgName: String?
}

struct TagDetail :Codable {
    
   var tag: String?
   var tagTip: String?
   var tagColor: String?
}
