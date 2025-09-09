import Foundation

struct LFConfigEnModel: Codable {
    let k1: String?
    let zanub: String?
    let zanuc: String?
    let zanud: String?
}

// 用于校验返回数据及错误码信息
struct LFValidateResp: Codable {
    let code: Int
    let msg: String?
    let fail: Bool?
    let success: Bool?
}

struct LFConfigItem: Codable {
    var rep: String?
    var name: String?
    var types: [Int]?
    var data: LFAnyCodable?
}

struct LFConfigModel: Codable {
    var items: [LFConfigItem]
    var ver: String?
    var riskControlInfoConfig: LFRiskControlInfoConfigModel?
}

struct LFAppExtData: Codable {
    var web_type : Int?
    var broadcaster_visit_user_detail_notify : Int?
    var web_config: LFWebConfigModel?
}
struct LFWebConfigModel: Codable {
    var bg_color: String?
    var status_bar_style: Int?
    var is_lf_web: Int?
    var web_path: String?
    var nav_title_color: String?
}

public struct LFSHConfigModel: Codable {
    var sh: Bool?
    var interval: Int?
    var remain_loop: Int?
}

struct LFRiskControlInfoConfigModel: Codable {
    var k_factor_num: String?
    var k_interval: Int?
    var k_factor: String?
    var extraValue: Int?
}

// MARK: - LFLoginModel
struct LFLoginModel: Codable {
    var isFirstRegister: Bool?
    var token: String?
    var userInfo: LFUserInfoModel?
}

// MARK: - LFUserInfoModel
struct LFUserInfoModel: Codable {
    var age: Int?
    var auditStatus: Int?
    var availableCoins: Int?
    var avatar: String?
    var avatarMiddleThumbUrl: String?
    var avatarThumbUrl: String?
    var avatarUrl: String?
    var birthday: String?
    var country: String?
    var followNum: Int?
    var isFriend: Bool?
    var gender: Int?
    var hasEquity: Bool?
    var isAnswer: Bool?
    var isBlock: Bool?
    var isHavePassword: Bool?
    var isInternal: Bool?
    var isMultiple: Bool?
    var isRecharge: Bool?
    var isReview: Bool?
    var isSwitchNotDisturbCall: Bool?
    var isSwitchNotDisturbIm: Bool?
    var isVip: Bool?
    var level: Int?
    var loginPkgName: String?
    var language: String?
    var nickname: String?
    var praiseNum: Int?
    var registerCountry: String?
    var registerPkgName: String?
    var rongcloudToken: String?
    var tagsList: [String]?
    var userId: String?
    var userType: Int?
    var about: String?
    var mediaList: [LFMediaModel]?
    var unitPrice: Int?
}

struct LFMediaModel: Codable {
    /// 币
    var coins: Int?
    /// 媒体 id
    var mediaId: String?
    /// 媒体路径
    var mediaPath: String?
    /// 媒体类型
    var mediaType: String?
    /// 媒体路径
    var mediaUrl: String?
    /// 媒体缩略图
    var middleThumbUrl: String?
    /// 排序
    var sort: Int?
    /// 缩略图
    var thumbUrl: String?
    /// 用户 id
    var userId: String?
}

struct LFStrategyModel: Codable {
    var isMatchCallFree: Bool?
    var initTab: Int?
    var isShowMatchGender: Bool?
    var genderMatchCoin: LFGenderMatchCoin?
    var isReviewPkg: Bool?
    var isShowLP: Bool?
    var lpDiscount: Int?
    var lpPromotionDiscount: Int?
    var payChannels: [String]?
    var isMaskOpen: Bool?
    var isShowBroadcasterRank: Bool?
    var isAutoAccept: Bool?
    var broadcasterWallTags: [String]?
    var tabType: Int?
    var isOpenBroacasterInvitation: Bool?
    var isOpenFlashChat: Bool?
    var videoStreamCategory: [String]?
    var flashChatConfig: LFFlashChatConfig?
    var isShowMatch: Bool?
    var isNewTppUsable: Bool?
    var userInvitation: LFUserInvitation?
    var topOfficialUserIds: [String]?
    var reviewOfficialBlacklistUserIds: [String]?
    var officialBlacklistUserIds: [String]?
    var imIncentiveBlacklistUserIds: [String]?
    var broadcasterFollowOfficialUserIds: [String]?
    var isDisplayNotDisturbCall: Bool?
    var isDisplayNotDisturbIm: Bool?
    var imSessionBalance: Int?
    var isShowFlowInfo: Bool?
    var isShowDeletedButton: Bool?
    var broadcasterWallTagList: [LFBroadcasterWallTagList]?
    var freeUserCallStaySecond: String?
    var freeUserImStaySecond: String?
    var rechargeUserCallStaySecond: String?
    var rechargeUserImStaySecond: String?
    var isRandomUploadPaidEvents: Bool?
    var isSwitchIMLimit: Bool?
    var isSwitchOneKeyFollow: Bool?
    var isSwitchIMIncentive: Bool?
    var isSwitchClub: Bool?
    var isShowRookieGuide: Bool?
    var isSwitchStrongGuide: Bool?
    var isCallRearCamera: Bool?
    var isCallCameraClose: Bool?
    var isShowAutoTranslate: Bool?
    var isSilence: Bool?
    var isRearCamera: Bool?
    var isCloseCamera: Bool?
    var isSwitchInstruct: Bool?
    var isForceEvaluationInstruct: Bool?
    var isSwitchExtraCategory: Bool?
    var isSwitchMultipleCall: Bool?
    var timestamp: String?
    var sayHiMaxCount: Int?
    var sayHiQuickPhrases: [String]?
    var userServiceAccountId: String?
    var broadcasterWallRegions: [String]?
    var userMultipleLevel: Int?
    var isReportFB: Bool?
    var isEnableGuardian: Bool?
    var isEnableCallCard: Bool?
    var isOpenSpeechToText: Bool?
    var voiceToTextConfig: LFVoiceToTextConfig?
    var isEnableGroupSend: Bool?
    var supportShowRoom: Bool?
    var newRelationMsgSizeLimit: Int?
    var unansweredGreetingExpireTTLHour: Int?
    var isOpenFlashChatOnRole: Bool?
    var broadcasterOnlineButton: String?
    var indianWallUnlock: String?
    var imSessionBroadcasterIds: [String]?
    var payScriptTriggerSecond: Int?
    var indiaWallCallButtonUI: String?
    var indiaWallLowCallUI: String?
    var indiaWallFaceFocus: Bool?
    var fakeBroadcasterPopupSecond: Int?
    var indiaRecommendShow: String?
}

// MARK: - LFFlashChatConfig
struct LFFlashChatConfig: Codable {
    var isSwitch: Bool?
    var isFreeCall: Bool?
    var residueFreeCallTimes: Int?
}

// MARK: - LFGenderMatchCoin
struct LFGenderMatchCoin: Codable {
    var maleCoins: Int?
    var femaleCoins: Int?
    var bothCoins: Int?
    var vipGoddessCoins: Int?
    var goddessCoins: Int?
}

// MARK: - LFUserInvitation
struct LFUserInvitation: Codable {
    var tipsTitle: String?
    var tipsContent: String?
    var popUpTitle: String?
    var popUpContent: String?
    var popUpbottom: String?
    var shareContent: String?
}

// MARK: - LFVoiceToTextConfig
struct LFVoiceToTextConfig: Codable {
    var voiceToTextSwitch: Bool?
    var voiceToTextUnitPrice: Int?
}

// MARK: - LFBroadcasterWallTagList
struct LFBroadcasterWallTagList: Codable {
    var tagName: String?
    var subTagList: [String]?
    var subTagInitIndex: Int?
}

enum LFLogEventSubtype:String {
    case enum_purchase_detail = "purchase_detail"
}

enum LFPurchaseDataKey: String {
    case enum_event = "event"
    case enum_code = "code"
    case enum_uuid = "uuid"
    case enum_orderId = "orderId"
    case enum_durationTime = "durationTime"
    case enum_elapsedTime = "elapsedTime"
    case enum_result = "result"
    case enum_resultCode = "resultCode"
}

enum LFFaqKey: String {
    case enum_event = "event"
    case enum_question = "question"
    case enum_isHelpful = "isHelpful"
    case enum_tm = "tm"
}

enum LFPurchaseEvent: String {
    /// 创建订单     调用创建订单接口前打点
    case enum_create_order = "create_order"
    /// 创建订单回调    无论回调成功与否都需要上传相应的响应
    case enum_create_order_resp = "create_order_resp"
    /// 调起支付     调起相应支付前打点
    case enum_launch_pay = "launch_pay"
    /// 支付回调
    case enum_launch_pay_resp = "launch_pay_resp"
    /// 校验订单     调用校验订单前打点
    case enum_verify_order = "verify_order"
    /// 校验订单回调
    case enum_verify_order_resp = "verify_order_resp"
    /// 消费订单 普通商品使用 调用消费接口前打点
    case enum_consume_order = "consume_order"
    /// 消费订单回调
    case enum_consume_order_resp = "consume_order_resp"
    /// 确认订单 订阅商品使用      调用确认接口前打点
    case enum_acknowledged_order = "acknowledged_order"
    /// 确认订单回调
    case enum_acknowledged_order_resp = "acknowledged_order_resp"
    /// 查询库存商品
    case enum_review_order = "review_order"
    /// 查询库存商品回调    无论回调成功与否都需要上传相应的响应
    case enum_review_order_resp = "review_order_resp"
}

struct LFOrderInfoModel: Codable {
    /// 商品编号
    var goodsCode: String?
    /// 商品名称
    var goodsName: String?
    /// 支付订单号
    var orderNo: String?
    /// 实付金额
    var paidAmount: Double?
    /// 实付币种
    var paidCurrency: String?
    /// 支付金额(美金)
    var payAmount: Double?
    /// 跳转地址
    var requestUrl: String?
    /// 平台订单号
    var tradeNo: String?
}

// MARK: - LFGoodsItem
struct LFCoinItem: Codable {
    let goodsId: String
    let code: String
    var icon: String?
    var type: String?
    var subType: Int?
    var discount: Double?
    var originalPrice: Double
    var price: Double
    var exchangeCoin: Int?
    var originalExchangeCoin: Int?
    var originalPriceRupee: Int?
    var priceRupee: Int?
    var localPaymentPriceRupee: Int?
    var isPromotion: Bool
    var localPayOriginalPrice: Int?
    var localPayPrice: Int?
    var tags: String?
    
    var invitationId: String?
    
    var extraCoinPercent: Int?
    var thirdpartyCoinPercent: Int?
    
    var surplusMillisecond: Int?
    var remainMilliseconds: Int?
    
    var capableRechargeNum: Int?
    var rechargeNum: Int?
    
    /// 活动名称
    var activityName: String?
    /// 活动大图
    var activityPic: String?
    /// 活动小图
    var activitySmallPic:String?
}

struct LFAnyCodable: Codable {
    var value_any: Any
    
    init<T>(_ value: T) {
        self.value_any = value
    }
    
    init(from decoder: Decoder) throws {
        let container_ = try decoder.singleValueContainer()
        if let intValue = try? container_.decode(Int.self) {
            value_any = intValue
        } else if let stringValue = try? container_.decode(String.self) {
            value_any = stringValue
        } else if let doubleValue = try? container_.decode(Double.self) {
            value_any = doubleValue
        } else if let boolValue = try? container_.decode(Bool.self) {
            value_any = boolValue
        } else if let arrayValue = try? container_.decode([LFAnyCodable].self) {
            value_any = arrayValue.map { $0.value_any }
        } else if let dictValue = try? container_.decode([String: LFAnyCodable].self) {
            value_any = dictValue.mapValues { $0.value_any }
        } else {
            value_any = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container_ = encoder.singleValueContainer()
        if let intValue = value_any as? Int {
            try container_.encode(intValue)
        } else if let stringValue = value_any as? String {
            try container_.encode(stringValue)
        } else if let doubleValue = value_any as? Double {
            try container_.encode(doubleValue)
        } else if let boolValue = value_any as? Bool {
            try container_.encode(boolValue)
        } else if let arrayValue = value_any as? [Any] {
            try container_.encode(arrayValue.map { LFAnyCodable($0) })
        } else if let dictValue = value_any as? [String: Any] {
            try container_.encode(dictValue.mapValues { LFAnyCodable($0) })
        } else {
            throw EncodingError.invalidValue(value_any, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    func lf_toInt() -> Int {
        if let intValue = value_any as? Int {
            return intValue
        } else if let stringValue = value_any as? String, let intValue = Int(stringValue) {
            return intValue
        }
        return 0
    }
    
    func lf_toDouble() -> Double {
        if let doubleValue = value_any as? Double {
            return doubleValue
        } else if let stringValue = value_any as? String, let doubleValue = Double(stringValue) {
            return doubleValue
        }
        return 0
    }
    
    func lf_toString() -> String {
        if let stringValue = value_any as? String {
            return stringValue
        } else if let intValue = value_any as? Int {
            return String(intValue)
        } else if let doubleValue = value_any as? Double {
            return String(doubleValue)
        }
        return ""
    }
    
    func lf_toBool() -> Bool {
        if let intValue = value_any as? Int {
            return intValue != 0
        } else if let boolValue = value_any as? Bool {
            return boolValue
        } else if let stringValue = value_any as? String {
            return stringValue.lowercased() == "true"
        }
        return false
    }
}

struct LFResModel<T: Decodable>: Decodable {
    let data: T?
    let key: String?
    let code: Int?
    let msg: String?
}

struct LFNilResModel: Decodable {}

// 错误信息
enum LFError: Error {
    case decodeFailure(_ msg: String?)
    case serverError(code:Int, msg: String?)
}

extension LFError: LocalizedError {
    public var serverCode: Int {
        switch self {
        case .serverError(let code, _):
            return code
        default:
            return 0
        }
    }
    
    public var msg: String? {
        switch self {
        case .decodeFailure(let msg):
            return msg
        case .serverError( _, let msg):
            return msg
        }
     }
    
    public var errorDescription: String? {
        return msg
    }
}
