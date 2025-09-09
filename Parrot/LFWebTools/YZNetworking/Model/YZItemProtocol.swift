//
//  YZItemProtocol.swift
//  WebTest
//
//  Created by dayu on 2025/5/27.
//

import Foundation
// 定义转换协议
protocol ConvertibleToEntity {
    associatedtype EntityType
    func toEntity() -> EntityType
}

// 扩展 LFCoinItem 实现转换协议
extension LFCoinItem: ConvertibleToEntity {
    func toEntity() -> CoinGoodEntity {
        let entity = CoinGoodEntity()
        entity.goodsId = goodsId
        entity.code = code
        entity.icon = icon
        entity.type = type
        entity.subType = subType
        entity.discount = discount ?? 0.0
        entity.originalPrice = originalPrice
        entity.price = price
        entity.exchangeCoin = exchangeCoin ?? 0
        entity.originalExchangeCoin = originalExchangeCoin
        entity.originalPriceRupee = originalPriceRupee
        entity.priceRupee = priceRupee
        entity.localPaymentPriceRupee = localPaymentPriceRupee
        entity.isPromotion = isPromotion
        entity.localPayOriginalPrice = localPayOriginalPrice
        entity.localPayPrice = localPayPrice
        entity.tags = tags
        entity.invitationId = invitationId
        entity.extraCoinPercent = extraCoinPercent
        entity.thirdpartyCoinPercent = thirdpartyCoinPercent
        entity.surplusMillisecond = surplusMillisecond
        entity.remainMilliseconds = remainMilliseconds
        entity.capableRechargeNum = capableRechargeNum
        entity.rechargeNum = rechargeNum
        entity.activityName = activityName
        entity.activityPic = activityPic
        entity.activitySmallPic = activitySmallPic
        return entity
    }
}

extension LFOrderInfoModel:ConvertibleToEntity {
    func toEntity() -> OrderInfoModel {
        let entity = OrderInfoModel()
        entity.goodsCode = goodsCode
        entity.goodsName = goodsName
        entity.orderNo = orderNo
        entity.paidAmount = payAmount
        entity.paidCurrency = paidCurrency
        entity.payAmount = payAmount
        entity.requestUrl = requestUrl
        entity.tradeNo = tradeNo
        return entity
    }
}
