//
//  CoinReository.swift
//  WebTest
//
//  Created by dayu on 2025/5/27.
//

import Foundation

@objc class CoinReository :NSObject {
    /* 商品列表查询接口 */
    @objc public static func coinGoodsSearch(completion:(([CoinGoodEntity],Bool) ->Void)?) async{
        guard let coins = try? await LFAPI.Goods.searchGoods() else {
            completion?([],false)
            return
        }
        completion?(coins.map{$0.toEntity()},true)
    }
    /* 创建充值订单接口 */
    @objc public static func coinRechargeCreate(goodsCode: String, completion:((OrderInfoModel,Bool) ->Void)?) async{
        guard let goods = try? await LFAPI.Goods.createOrderInfo(goodsCode: goodsCode, payChannel: "IAP") else {
            completion?(OrderInfoModel(),false)
            return
        }
        guard let goodsOC = goods.data?.toEntity() else {
            completion?(OrderInfoModel(),false)
            return
        }
        completion?(goodsOC,true)
    }
    /* IPA订单支付校验接口 */
    @objc public static func independentVerify(orderNo:String,payload:String,transactionId:String,completion:((Bool) -> Void)?) async{
        guard let data = try? await LFAPI.Goods.independentVerify(orderNo: orderNo, payload: payload, transactionId: transactionId) else {
            completion?(false)
            return
        }
        completion?(data.data ?? false)
    }
    
    /* 审核模式app扣减金币 */
    @objc public static func reviewModeConsume(outlay:Int,source:String,completion:((Bool) -> Void)?) async{
        guard let data = try? await LFAPI.Goods.reviewModeConsume(path:LFAPIMap.coinsume  , outlay: outlay, source: source) else{
            completion?(false)
            return
        }
        completion?(data.data ?? false)
    }
}
