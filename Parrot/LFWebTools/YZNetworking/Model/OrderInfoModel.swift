//
//  model.swift
//  WebTest
//
//  Created by dayu on 2025/5/27.
//

import Foundation
@objc class OrderInfoModel: NSObject {
    /// 商品编号
    @objc  var goodsCode: String?
    /// 商品名称
    @objc  var goodsName: String?
    /// 支付订单号
    @objc  var orderNo: String?
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
