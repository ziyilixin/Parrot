//
//  LFPurchaseManager.swift
//  Santai
//
//  Created by Giftic on 2024/11/19.
//

import UIKit
import Foundation
import StoreKit

/// 内购
@objc class LFPurchaseManager: NSObject {
    var buyBlock: ((Bool) -> Void)?
    @objc static let shared = LFPurchaseManager()
    
    private var unfinishedOrders:[String:LFOrderInfoModel] = [:]
    
    private var uuid:String?
    
    private var isVip = false
    
    private var createOrderStartTime:Int?
    private var elapsedTime = 0
    
    private var launchPayStartTime:Int?
    private var reviewStartTime:Int?
    private var startVerifyTime:Int?
    private var consumeStartTime:Int?
    
    
    /// 创建订单重试次数
    private var retryCount = 0
    
    
    private var retryVerifyTimes = 0
    
    private var isRestore = false
    
    
    // MARK: - Public
    /**
     添加/移除支付观察者
     */
    public func addPaymentObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    @objc public func removePaymentObserver() {
        SKPaymentQueue.default().remove(self)
    }
    
    /// 初始操作
    @objc public func initAction() {
        addPaymentObserver()
        unfinishedOrders = LFUserDefaults.standard.getPayOrderInfo()
        if !unfinishedOrders.isEmpty {
            // 还有未完成的订单
            restoreBuy()
        }
    }
    
    @objc public func buy(_ goodsCode: String, paySource:String = "", invitationId: String = "", eventExtData: [String: Any] = [:], broadcasterId: String = "", scriptId: String = "", routerPaths: [String] = [],buyBlock: @escaping ((Bool) -> Void)) {
        guard SKPaymentQueue.canMakePayments() else {
            // 内购不可用
            paymentFailure(LFGlobalStrings.apple_pay_not_available)
            return
        }
        
        Task {
            self.buyBlock = buyBlock
            retryCount = 0
            LFLoading.show()
            createOrderInfo(goodsCode, paySource: paySource, invitationId: invitationId, eventExtData: eventExtData, broadcasterId: broadcasterId, scriptId: scriptId, routerPaths: routerPaths)
        }
    }
    
    /// 创建商品订单
    private func createOrderInfo(_ goodsCode: String, paySource:String = "", invitationId: String = "", eventExtData: [String: Any] = [:], broadcasterId: String = "", scriptId: String = "", routerPaths: [String] = []){
        Task {
            do {
                let respon = try await LFAPI.Goods.createOrderInfo(
                    goodsCode: goodsCode,
                    payChannel: "IAP",
                    paySource: paySource,
                    invitationId: invitationId,
                    eventExtData: eventExtData,
                    broadcasterId: broadcasterId,
                    scriptId: scriptId,
                    routerPaths: routerPaths
                )
                
                if respon?.code == 0, let order = respon?.data {
                    retryCount = 0
                    if order.goodsCode == nil || order.orderNo == nil {
                        paymentFailure()
                        return
                    }
                    
                    // 打点
                    eventCreateOrderResp(result: "success", goodsCode: order.goodsCode ?? "")
                    
                    unfinishedOrders[order.goodsCode ?? ""] = order
                    // 缓存起来
                    LFUserDefaults.standard.setPayOrderInfo(unfinishedOrders)
                    
                    // 发起内购请求
                    initiatePurchaseRequest(order.goodsCode ?? "")
                } else {
                    paymentFailure(respon?.msg)
                    // 请求创建商品订单失败，打点
                    eventCreateOrderResp(result: "\(String(describing: respon?.data))", goodsCode: goodsCode)
                }
            } catch {
                print(error.localizedDescription)
                createOrderInfoFailure(error, goodsCode, paySource: paySource, invitationId: invitationId)
            }
        }
    }
    
    
    /// 创建订单失败重试
    /// - Parameters:
    ///   - error: 错误
    ///   - goods: 商品
    ///   - paySource: string
    fileprivate func createOrderInfoFailure(_ error: Error, _ goodsCode: String, paySource:String = "", invitationId: String = "") {
        if retryCount < 5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {[weak self] in
                self?.retryCount += 1
                self?.createOrderInfo(goodsCode, paySource: paySource, invitationId: invitationId)
            }
        } else {
            paymentFailure(error.localizedDescription)
            // 请求创建商品订单失败，打点
            eventCreateOrderResp(result: error.localizedDescription, goodsCode: goodsCode)
        }
    }
    
    /// 发起内购请求
    private func initiatePurchaseRequest(_ goodsCode: String) {
        let set = Set.init([goodsCode])
        let request = SKProductsRequest(productIdentifiers: set)
        request.delegate = self
        request.start()
    }
    
    /// 内购完成
    func purchaseComplete(transaction: SKPaymentTransaction) {
        
        eventVerifyOrder(transaction)
        
        do {
            //获取交易凭证
            guard let recepitUrl = Bundle.main.appStoreReceiptURL else {
                paymentFailure(LFGlobalStrings.transaction_voucher_empty)
                LFLoading.hide()
                return
            }
            let data = try Data(contentsOf: recepitUrl)
            
            let transactionCertificate = data.base64EncodedString(options: [])
            
            independentVerify(payload: transactionCertificate, transaction: transaction)
            
        } catch {
            paymentFailure(error.localizedDescription)
        }
        
    }
    
    
    /// 独立校验
    private func independentVerify(payload:String, transaction:SKPaymentTransaction) {
        Task {
            let goods_code = transaction.payment.productIdentifier
            let transaction_identifier = transaction.transactionIdentifier ?? ""
            do {
                let respon = try await LFAPI.Goods.independentVerify(
                    orderNo: getPayOrderInfo(goods_code)?.orderNo ?? "",
                    payload: payload,
                    transactionId: transaction_identifier
                )
                if respon?.data == true {
                    
                    /// 独立校验成功，打点
                    eventVerifyOrderResp(goodsCode: goods_code)
                    
                    finish_fransaction(transaction)
                    
                } else {
                    paymentFailure()
                    /// 独立校验失败，打点
                    eventVerifyOrderResp(goodsCode: goods_code, result: "\(LFGlobalStrings.verify_fail):\(String(describing: respon?.data))")
                }
                
            } catch {
                
                retryIndependentVerify(error, payload: payload, transaction: transaction)
            }
        }
    }
    
    fileprivate func retryIndependentVerify(_ error: Error, payload:String, transaction: SKPaymentTransaction) {
        
        if retryVerifyTimes < 5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {[weak self] in
                self?.retryVerifyTimes += 1
                self?.independentVerify(payload: payload, transaction: transaction)
            }
        } else {
            paymentFailure(error.localizedDescription)
            /// 独立校验失败，打点
            let goods_code = transaction.payment.productIdentifier
            eventVerifyOrderResp(goodsCode: goods_code, result: error.localizedDescription)
        }
    }
    
    
    /// 把交易标注完成
    private func finish_fransaction(_ transaction: SKPaymentTransaction) {
        eventConsumeOrder(goodsCode: transaction.payment.productIdentifier)
        // 注销交易
        SKPaymentQueue.default().finishTransaction(transaction)
        eventConsumeOrderResp(goodsCode: transaction.payment.productIdentifier, result: "success")
        payment_success(transaction.payment.productIdentifier)
    }
    
    /// 内购成功
    private func payment_success(_ goodsCode: String){
        /// 内购成功打点
        paymentSuccessRecord(goodsCode)
        /// 清除订单缓存
        cleanOrderInfoCache(goodsCode)
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.buyBlock?(true)
            LFLoading.hide()
        }
    }
    
    /// 内购成功打点
    /// - Parameter goodsCode: String
    private func paymentSuccessRecord(_ goodsCode: String) {
        ///第三方打点
        let order = getPayOrderInfo(goodsCode)
        LFSdkStatistics.shared.iap_purchase_record(paidAmount: order?.paidAmount ?? 0, paidCurrency: order?.paidCurrency ?? "")
    }
    
    /// 内购失败
    private func paymentFailure(_ message:String? = nil) {
        DispatchQueue.main.async {
            LFLoading.showMessage(message ?? LFGlobalStrings.purchase_failure)
        }
    }
    
    /// 恢复未完成的订单
    private func restoreBuy(){
        DispatchQueue.global().async {[weak self] in
            self?.eventReviewOrderInfo()
            SKPaymentQueue.default().restoreCompletedTransactions()
            
            let transactions = SKPaymentQueue.default().transactions
            for item in transactions {
                SKPaymentQueue.default().finishTransaction(item)
            }
        }
    }
    
    /// 根据商品code获取支付订单信息
    private func getPayOrderInfo(_ goodsCode:String) -> LFOrderInfoModel? {
        return unfinishedOrders[goodsCode]
    }
    
    /// 清除订单缓存
    private func cleanOrderInfoCache(_ goodsCode:String){
        unfinishedOrders.removeValue(forKey: goodsCode)
        LFUserDefaults.standard.setPayOrderInfo(unfinishedOrders)
    }
}


// MARK: - 发起内购的请求监听
extension LFPurchaseManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        Task {
            LFLoading.hide()
            
            guard let product = response.products.first else {
                /// 没有对应的商品id
                paymentFailure(LFGlobalStrings.no_relevant_product)
                return
            }
            
            if let payOrder = getPayOrderInfo(product.productIdentifier) {
                // 打个点
                logLaunchPayEvent(payOrder)
            }
            
            let payment = SKMutablePayment.init(product: product)
            payment.quantity = 1
            SKPaymentQueue.default().add(payment)
        }
    }
}


// MARK: - 内购监听
extension LFPurchaseManager:SKPaymentTransactionObserver {
    /// 内购结果
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for item in transactions {
            switch item.transactionState {
                
            case .purchasing:
                /// 购买中
                Task {
                    LFLoading.show()
                }
                break
                
            case .purchased, .restored:
                /// 购买完成 || 购买已恢复
                if isRestore {
                    /// 恢复购买，打点
                    eventReviewOrderResp(item.payment.productIdentifier)
                }
                
                retryVerifyTimes = 0
                
                eventLaunchPayResp(goodsCode: item.payment.productIdentifier, result: "success")
                
                purchaseComplete(transaction: item)
                break
            case .failed:
                // 购买失败,
                self.buyBlock?(false)
                LFLoading.hide()
                // 注销交易
                SKPaymentQueue.default().finishTransaction(item)
                // 打点
                eventLaunchPayResp(goodsCode: item.payment.productIdentifier, result: "error")
                // 清除缓存
                cleanOrderInfoCache(item.payment.productIdentifier)
                if let error = item.error as NSError? {
                    if error.code == SKError.paymentCancelled.rawValue {
                        // 内购被用户主动取消
                        paymentFailure(LFGlobalStrings.purchase_cancel)
                        return
                    }
                }
                
                paymentFailure()
                break
            case .deferred:
                break
            default:
                paymentFailure()
                break
            }
        }
    }
}



// MARK: - 打点
extension LFPurchaseManager {
    /// 开始创建订单
    private func  eventCreateOrder(goodsCode:String) {
        createOrderStartTime = createOrderStartTime ?? current_timestamp()
        let createDuration = current_timestamp() - createOrderStartTime!
        elapsedTime = createDuration
        createOrderStartTime = current_timestamp()
        
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_create_order,
            goodsCode: goodsCode,
            durationTime: createDuration,
            elapsedTime: elapsedTime
        )
    }
    
    /// 创建订单结果
    private func eventCreateOrderResp(
        result:String = "1",
        resultCode:Int = 0,
        goodsCode:String = "",
        orderNo:String = ""
    ) {
        createOrderStartTime = createOrderStartTime ?? current_timestamp()
        let createOrderDuration = current_timestamp() - createOrderStartTime!;
        elapsedTime += createOrderDuration
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_create_order_resp,
            goodsCode: goodsCode,
            durationTime: createOrderDuration,
            elapsedTime: elapsedTime,
            orderId: orderNo,
            result: result,
            resultCode: resultCode
        )
    }
    
    /// 调起支付
    private func logLaunchPayEvent(_ order: LFOrderInfoModel) {
        launchPayStartTime = launchPayStartTime ?? current_timestamp()
        let duration = current_timestamp() - launchPayStartTime!
        elapsedTime += duration
        launchPayStartTime = current_timestamp()
        
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_launch_pay,
            goodsCode: order.goodsCode ?? "",
            durationTime: duration,
            elapsedTime: elapsedTime,
            orderId: order.orderNo ?? ""
        )
    }
    
    /// 查询库存商品
    private func eventReviewOrderInfo(_ goodsCode:String = "") {
        reviewStartTime = reviewStartTime ?? current_timestamp()
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_review_order,
            goodsCode: goodsCode,
            durationTime: 0,
            elapsedTime: 0,
            orderId: getPayOrderInfo(goodsCode)?.orderNo ?? ""
        )
    }
    
    /// 查询库存商品
    private func eventReviewOrderResp(_ goodsCode:String) {
        reviewStartTime = reviewStartTime ?? current_timestamp()
        let reviewDuration = current_timestamp() - reviewStartTime!
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_review_order_resp,
            goodsCode: goodsCode,
            durationTime: reviewDuration,
            elapsedTime: reviewDuration,
            orderId: getPayOrderInfo(goodsCode)?.orderNo ?? "",
            result: ""
        )
    }
    
    /// 支付回调
    private func eventLaunchPayResp(goodsCode:String, result:String = "1") {
        //补单时_launchPayStartTime开始时间为空
        launchPayStartTime = launchPayStartTime ?? current_timestamp()
        let launchPayDuration = current_timestamp() - launchPayStartTime!
        elapsedTime += launchPayDuration
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_launch_pay_resp,
            goodsCode: goodsCode,
            durationTime: launchPayDuration,
            elapsedTime: elapsedTime,
            orderId: getPayOrderInfo(goodsCode)?.orderNo ?? "",
            result: result
        )
    }
    
    /// 校验订单
    private func eventVerifyOrder(_ transaction: SKPaymentTransaction) {
        let goods_code = transaction.payment.productIdentifier
        startVerifyTime = startVerifyTime ?? current_timestamp()
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_verify_order,
            goodsCode: transaction.payment.productIdentifier,
            durationTime: 0,
            elapsedTime: elapsedTime,
            orderId: getPayOrderInfo(goods_code)?.orderNo ?? "",
            result: "success"
        )
    }
    
    
    
    /// 校验订单回调
    private func eventVerifyOrderResp(goodsCode:String, result:String = "success", resultCode:Int = 0) {
        startVerifyTime = startVerifyTime ?? current_timestamp()
        let verifyDuration = current_timestamp() - startVerifyTime!
        elapsedTime += verifyDuration
        
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_verify_order_resp,
            goodsCode: goodsCode,
            durationTime: verifyDuration,
            elapsedTime: elapsedTime,
            orderId: getPayOrderInfo(goodsCode)?.orderNo ?? "",
            result: result,
            resultCode: resultCode
        )
    }
    
    /// 消费订单
    private func eventConsumeOrder(goodsCode:String) {
        consumeStartTime = consumeStartTime ?? current_timestamp()
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_consume_order,
            goodsCode: goodsCode,
            durationTime: 0,
            elapsedTime: elapsedTime,
            orderId: getPayOrderInfo(goodsCode)?.orderNo ?? ""
        )
    }
    
    /// 消费订单回调
    private func eventConsumeOrderResp(goodsCode:String, result:String = "success", resultCode:Int = 0) {
        consumeStartTime = consumeStartTime ?? current_timestamp()
        let payDuration = current_timestamp() - consumeStartTime!
        elapsedTime += payDuration
        logLiveChatEvent(
            event: LFPurchaseEvent.enum_consume_order_resp,
            goodsCode: goodsCode,
            durationTime: payDuration,
            elapsedTime: elapsedTime,
            orderId: getPayOrderInfo(goodsCode)?.orderNo ?? "",
            result: result,
            resultCode: resultCode
        )
    }
    
    
    func current_timestamp() -> Int {
        let now = Date()
        let timeInterval = now.timeIntervalSince1970 * 1000
        return Int(timeInterval)
    }
    
    ///
    func logLiveChatEvent(
        event:LFPurchaseEvent,
        goodsCode:String,
        durationTime:Int = 0,
        elapsedTime:Int = 0,
        orderId:String = "",
        result:String = "success",
        resultCode:Int = 0
    ) {
        let data:[String:Any] = [
            LFPurchaseDataKey.enum_event.rawValue: event.rawValue,
            LFPurchaseDataKey.enum_code.rawValue: goodsCode,
            LFPurchaseDataKey.enum_uuid.rawValue: uuid ?? UUID().uuidString,
            LFPurchaseDataKey.enum_orderId.rawValue: orderId,
            LFPurchaseDataKey.enum_result.rawValue: result,
            LFPurchaseDataKey.enum_resultCode.rawValue: resultCode,
            LFPurchaseDataKey.enum_durationTime.rawValue: durationTime,
            LFPurchaseDataKey.enum_elapsedTime.rawValue: elapsedTime,
        ]
        
        Task {
            let _ = try? await LFAPI.LFLog.logLiveChat(parameters: data)
        }
    }
}
