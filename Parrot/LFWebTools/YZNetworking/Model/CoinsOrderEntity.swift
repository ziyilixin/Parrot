//
//  CoinsOrderEntity.swift
//  WebTest
//
//  Created by dayu on 2025/5/26.
//

import Foundation

struct CoinsOrderEntity : Codable {
    var goodsCode: String?
    var goodsName: String?
    var orderNo: String?
    var paidAmount: String?
    var paidCurrency: String?
    var payAmount: String?
}
