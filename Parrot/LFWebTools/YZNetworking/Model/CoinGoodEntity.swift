//
//  CoinGoodEntity.swift
//  WebTest
//
//  Created by dayu on 2025/5/26.
//

import Foundation
@objc class CoinGoodEntity :NSObject {
    @objc var goodsId: String?
    @objc var code: String?
    @objc var icon: String?
     var type: String?
     var subType: Int?
    @objc  var discount: Double = 0.0
    @objc var originalPrice: Double = 0.0
    @objc var price: Double = 0.0
    @objc  var exchangeCoin: Int = 0
     var originalExchangeCoin: Int?
     var originalPriceRupee: Int?
     var priceRupee: Int?
     var localPaymentPriceRupee: Int?
    @objc var isPromotion: Bool = false
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
    @objc var activityName: String?
    /// 活动大图
    @objc var activityPic: String?
    /// 活动小图
    @objc var activitySmallPic:String?
}
