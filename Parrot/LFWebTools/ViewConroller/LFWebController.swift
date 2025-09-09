@preconcurrency import WebKit
import UIKit
import SwiftUI
import Foundation
import StoreKit
import SnapKit
import Security

@objc class LFWebController: UIViewController {
    var isScreenCaptureDisabled = false
    var webview: WKWebView!
    var isNavigationBarHidden_ = true
    var isProgressHidden = false
    var browserUrl:String?
    var onDismiss: (() -> Void)?
    
    var tapCount = 0
    
    private var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // LFLoading.show()
        LFPurchaseManager.shared.initAction()
        
        view.backgroundColor = .lf_hex(hex: web_bg_color)
        
        //设置白昼模式
        overrideUserInterfaceStyle = .light
        configureWebView()
        
        if !isNavigationBarHidden_ {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(isNavigationBarHidden_, animated: false)
        if !isNavigationBarHidden_ {
            updateNavigationBar()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    
    override func loadView() {
        super.loadView()
        view = LFScreenShieldView.create()
    }
    
    ///【LivChat】状态栏为白色
    override var preferredStatusBarStyle: UIStatusBarStyle { web_status_bar_style }
    
    lazy var standard_appearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor:  UIColor.lf_hex(hex: web_nav_title_color),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .lf_hex(hex: web_bg_color)
        return appearance
    }()
    
    private func updateNavigationBar() {
        self.navigationController?.navigationBar.standardAppearance = standard_appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = standard_appearance
        if #available(iOS 15.0, *) {
            self.navigationController?.navigationBar.compactAppearance = standard_appearance
            self.navigationController?.navigationBar.compactScrollEdgeAppearance = standard_appearance
        }
    }
    
    lazy var backBarButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: LFGlobalStrings.key_chevron_left, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        button.tintColor = .lf_hex(hex: web_nav_title_color)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(backBarItemAction(_:)), for: .touchUpInside)
        return button
    }()
    @objc func backBarItemAction(_ item: UIBarButtonItem) {
        if webview.canGoBack {
            webview.goBack()
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    func configNavTitle(_ title: String?, tintColor: UIColor = UIColor.white, font: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)) {
        navigationItem.title = title
        standard_appearance.titleTextAttributes = [.foregroundColor: UIColor.lf_hex(hex: web_nav_title_color), .font: font]
        navigationController?.navigationBar.standardAppearance = standard_appearance
        navigationController?.navigationBar.scrollEdgeAppearance = standard_appearance
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactAppearance = standard_appearance
            navigationController?.navigationBar.compactScrollEdgeAppearance = standard_appearance
        }
    }
    
    private func configureWebView() {
        let userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        
        // 检查 WKWebpagePreferences 是否可用
        if #available(iOS 14.0, *) {
            let webpagePreferences = WKWebpagePreferences()
            webpagePreferences.allowsContentJavaScript = true
            config.defaultWebpagePreferences = webpagePreferences
        } else {
            // iOS 14 以下的兼容写法
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = true
            config.preferences = preferences
        }
        // 允许内联媒体播放
        config.allowsInlineMediaPlayback = true
        // 允许自动播放
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // 初始脚本配置
        let data: [String: Any] = [
            LFGlobalStrings.key_http_headers: LFAPIClient.shared.baseHeaders,
            LFGlobalStrings.key_app_base_url: [
                LFGlobalStrings.key_h5: LFAppDomain.h5_domain,
                LFGlobalStrings.key_app: LFAppDomain.app_domain,
                LFGlobalStrings.key_im: LFAppDomain.im_domain,
                LFGlobalStrings.key_log: LFAppDomain.log_domian,
                LFGlobalStrings.key_privacy_link: LFAppLink.privacy_url,
                LFGlobalStrings.key_terms_link: LFAppLink.terms_url
            ],
            LFGlobalStrings.key_bearer: LFGlobalStrings.value_bearer,
            LFGlobalStrings.key_app_package_info: [
                LFGlobalStrings.key_lan_id: Locale.current.language.languageCode?.identifier ?? "en",
                LFGlobalStrings.key_app_name: Bundle.main.object(forInfoDictionaryKey: LFGlobalStrings.key_cf_bundle_display_name) as? String ?? Bundle.main.object(forInfoDictionaryKey: LFGlobalStrings.key_cf_bundle_name) as? String ?? "",
                LFGlobalStrings.key_package_name: Bundle.main.bundleIdentifier ?? "",
                LFGlobalStrings.key_app_icon_url: LFAppLink.app_logo,
                LFGlobalStrings.key_app_id: LFAppConfig.app_id,
            ],
            LFGlobalStrings.key_is_debug: is_debug_fl,
            LFGlobalStrings.key_app_config_data: LFWebData.shared.configModel?.toDictionary() ?? [:],
            LFGlobalStrings.key_strategy_data: LFWebData.shared.strategyModel?.toDictionary() ?? [:],
            LFGlobalStrings.key_user_info: LFWebData.shared.userModel?.toDictionary() ?? [:],
            // LivChat web新增
            LFGlobalStrings.key_safe_area_top: SafeAreaTool.safe_top,
            LFGlobalStrings.key_safe_area_bottom: SafeAreaTool.safe_bottom,
            // 是否已绑过邀请码
//            LFGlobalStrings.key_bind_invitation_code: InvitationViewModel_.shared.invitation_user_ids.contains(UserViewModel_.shared.user_id)
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: data )
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        // JavaScript脚本
        let script = String(format: LFGlobalStrings.script_string_1, jsonString)
        userContentController.addUserScript(WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        
        // 添加各个H5功能对应的JS监听
        let message_handlers = LFGlobalStrings.all_js_event
        // 添加JS监听
        message_handlers.forEach {
            userContentController.add(WeakScriptMessageHandler(delegate: self), name: $0)
        }
        
        config.userContentController = userContentController
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = false
        config.allowsAirPlayForMediaPlayback = false
        webview = WKWebView(frame: .zero, configuration: config)
        webview.backgroundColor = .clear
        webview.scrollView.backgroundColor = .lf_hex(hex: web_bg_color)
        webview.scrollView.bounces = false
        webview.evaluateJavaScript(String(format: LFGlobalStrings.script_string_2, web_bg_color), completionHandler: nil)
        webview.navigationDelegate = self
        webview.uiDelegate = self
        
        webview.scrollView.contentInsetAdjustmentBehavior = .never
        webview.scrollView.showsVerticalScrollIndicator = false
        webview.scrollView.showsHorizontalScrollIndicator = false
        webview.allowsLinkPreview = false
        
        // 禁止侧滑
        webview.allowsBackForwardNavigationGestures = false
        
        view.addSubview(webview)
        webview.snp.makeConstraints { make in
            if isNavigationBarHidden_ {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(view.safeAreaLayoutGuide)
            }
            make.leading.trailing.bottom.equalToSuperview()
            //make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // 添加进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        progressView.tintColor = .blue
        progressView.alpha = isProgressHidden ? 0.0 : 1.0
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            if isNavigationBarHidden_ {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(view.safeAreaLayoutGuide)
            }
            make.leading.trailing.equalToSuperview()
        }
        webview.addObserver(self, forKeyPath: LFGlobalStrings.estimated_progress, options: .new, context: nil)
        
        if let browserUrl = browserUrl {
            webview.load(URLRequest(url: URL(string: browserUrl)!))
        } else {
            print("webUrl==\(LFAppDomain.web_domain)")
            webview.load(URLRequest(url: URL(string: LFAppDomain.web_domain)!))
            
            // 如果不需要本地召回功能，注释这段代码
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                LFLocalNotificationManager.init_config()
                Task { await LFAPI.LFSecurity.riskInfoUpload() }
            }
        }
        
        configNotification()
    }
    
    private func configNotification() {
        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self, self.isScreenCaptureDisabled else { return }
            self.onScreenShotDetected()
        }
        
        NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.onScreenCapture()
        }
        
        NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.onScreenCapture()
        }
        
        // 【LivChat】监听打开客服通知
        NotificationCenter.default.addObserver(forName: .init(LFGlobalStrings.open_customer_service_noti), object: nil, queue: .main) { [weak self] _ in
            guard let self = self, self == navigationController?.viewControllers.first else { return }
            on_open_vip_service()
        }
        
        // 前台监听
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // 后台监听
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // LivChat web新增
        if !is_livchat_web {
            // 监听键盘出现
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShow(_:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )
            
            // 监听键盘消失
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide(_:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
        }
    }
    
    /// 观察 estimatedProgress 以更新进度条
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == LFGlobalStrings.estimated_progress {
            progressView.progress = Float(webview.estimatedProgress)
            progressView.isHidden = webview.estimatedProgress == 1
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        // 安全检查webview是否为nil，防止崩溃
        if let webview = webview {
            webview.removeObserver(self, forKeyPath: LFGlobalStrings.estimated_progress)
            webview.configuration.userContentController.removeAllUserScripts()
        }
    }
}
// MARK: - WKNavigationDelegate
extension LFWebController: WKNavigationDelegate, WKUIDelegate {
    func checkHttp(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.scheme == LFGlobalStrings.key_http || components?.scheme == LFGlobalStrings.key_https
    }
    
    @objc func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LFLoading.hide()
        if let curTitle = self.webview.title, !curTitle.isEmpty {
            configNavTitle(curTitle)
        } else {
            configNavTitle(self.title)
        }
        
        progressView.isHidden = true
        // 注入JS
        var param: [String : String] = [:]
        param[LFGlobalStrings.new_tpp_close] = LFGlobalStrings.new_tpp_close
        param[LFGlobalStrings.open_vip_service] = LFGlobalStrings.open_vip_service
        param[LFGlobalStrings.new_tpp_log_event] = LFGlobalStrings.new_tpp_log_event
        param[LFGlobalStrings.h5_recharge] = LFGlobalStrings.h5_recharge
        param[LFGlobalStrings.recharge_source] = LFGlobalStrings.recharge_source
        var jsonStr: String = ""
        for (_, dic) in param.enumerated() {
            jsonStr += String(format: LFGlobalStrings.script_string_3, dic.key, dic.value)
        }
        jsonStr.removeLast()
        webView.evaluateJavaScript(String(format: LFGlobalStrings.script_string_4, jsonStr)) { response, error in }
    }
    
    @objc func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if !checkHttp(navigationAction.request.url) {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
        }
        decisionHandler(.allow)
    }
    
    @objc func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // 拦截权限弹窗请求
    @available(iOS 15.0, *)
    @objc func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        // 自动允许权限
        decisionHandler(.grant)
    }
}
// MARK: - WKScriptMessageHandler
extension LFWebController: WKScriptMessageHandler {
    @objc func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // print("didReceive: \(message.name) \(message.body)")
        switch message.name {
        case LFGlobalStrings.logout:
            // 退出登录
            logout()
            reply_success(to: message)
        case LFGlobalStrings.open_app_browser:
            //【灵蜂】打开应用内浏览器
            reply_success(to: message)
            guard let url_str = message.body as? String, let url = URL(string: url_str) else {
                return
            }
            open_app_browser(url: url)
        case LFGlobalStrings.open_h5_browser:
            //【LivChat】打开应用内浏览器
            guard let dictionary = JSONUtils.toDictionary(from: message.body) else {
                print("无法解析为 [String: Any]")
                return
            }
            
            guard let url_str = dictionary[LFGlobalStrings.key_url] as? String, let url = URL(string: url_str) else {
                return
            }
            let title = dictionary[LFGlobalStrings.key_title] as? String
            open_app_browser(url: url, title: title ?? "")
        case LFGlobalStrings.open_link:
            // 打开外部浏览器
            if let urlStr = message.body as? String, let url = URL(string: urlStr) {
                open_external_browser(url: url)
            }
            reply_success(to: message)
        case LFGlobalStrings.log_purchase_fb, LFGlobalStrings.log_purchase_apps, LFGlobalStrings.log_purchase_firebase, LFGlobalStrings.log_purchase_aj:
            guard let dictionary = JSONUtils.toDictionary(from: message.body) else {
                print("无法解析为 [String: Any]")
                reply_success(to: message)
                return
            }
            
            print("解析后的字典: \(dictionary)")
            
            let logType: PurchaseLogType = {
                switch message.name {
                case LFGlobalStrings.log_purchase_fb:
                    return .Facebook
                case LFGlobalStrings.log_purchase_firebase:
                    return .Firebase
                case LFGlobalStrings.log_purchase_apps:
                    return .AppsFlyer
                default:
                    return .AJ
                }
            }()
            
            log_purchase(data: dictionary, log_type: logType)
            reply_success(to: message)
        case LFGlobalStrings.open_app_purchase:
            // 原生支付
            if let dictionary = JSONUtils.toDictionary(from: message.body) {
                print("解析后的字典: \(dictionary)")
                open_in_app_purchase(data: dictionary)
            } else {
                print("无法解析为 [String: Any]")
            }
            reply_success(to: message)
        case LFGlobalStrings.open_app_store_review:
            // App评价弹窗
            open_app_store_review()
            reply_success(to: message)
        case LFGlobalStrings.set_screen_capture_disabled:
            // 禁止截屏、录屏
            set_screen_capture_disabled(isDisabled: message.body as? String == LFGlobalStrings.key_true)
            reply_success(to: message)
        case LFGlobalStrings.open_app_settings:
            // 打开设置
            open_app_settings()
            reply_success(to: message)
        case LFGlobalStrings.screen_wakelock:
            // 禁止息屏
            toggle_wake_lock(isEnabled: message.body as? String == LFGlobalStrings.key_true)
            reply_success(to: message)
        case LFGlobalStrings.update_coins:
            // 更新金币数
            if let coinsStr = message.body as? String, let coins = Int(coinsStr) {
                update_coins(coins: coins)
            }
            reply_success(to: message)
        case LFGlobalStrings.new_tpp_close:
            //【LivChat】关闭当前页面
            on_new_tpp_close()
            //【灵蜂】关闭当前页面
            self.navigationController?.popViewController(animated: true)
        case LFGlobalStrings.open_vip_service:
            if is_livchat_web {
                //【LivChat】打开官方客服私聊页
                if self != navigationController?.viewControllers.first {
                    // 不在Web主界面，发送通知
                    NotificationCenter.default.post(name: .init(LFGlobalStrings.open_customer_service_noti), object: nil)
                    //关闭当前页面
                    self.navigationController?.popViewController(animated: true)
                } else {
                    // 在Web主界面，直接打开客服页
                    on_open_vip_service()
                }
            } else {
                //【灵蜂】打开官方客服私聊页
                guard let userServiceAccountId = LFWebData.shared.strategyModel?.userServiceAccountId else { return }
                let vc = LFWebController()
                vc.browserUrl = String(format: LFGlobalStrings.lf_chat_url, LFAppDomain.web_domain, userServiceAccountId)
                vc.isNavigationBarHidden_ = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case LFGlobalStrings.h5_recharge:
            if is_livchat_web {
                //【LivChat】打开充值页面
                on_recharge()
            } else {
                //【灵蜂】打开充值页面
                let vc = LFWebController()
                vc.browserUrl = String(format: LFGlobalStrings.lf_recharge_url, LFAppDomain.web_domain)
                vc.isNavigationBarHidden_ = true
                present(UINavigationController(rootViewController: vc), animated: true)
                vc.onDismiss = { [weak self] in
                    guard let self else { return }
                    self.update_coins(coins: 0)
                }
            }
        case LFGlobalStrings.allows_back_forward_navigation_gestures:
            //【灵蜂】允许侧滑返回手势
            guard let messageBody = message.body as? String else { return }
            if messageBody == "false" {
                webview.allowsBackForwardNavigationGestures = false
            } else if messageBody == "true" {
                webview.allowsBackForwardNavigationGestures = true
            }
        case LFGlobalStrings.log_firebase_event:
            //【灵蜂】Firebase打点
            break
        case LFGlobalStrings.open_file_browser:
            //【LivChat】打开文件选择器
            open_file_browser()
            break
        case LFGlobalStrings.open_album:
            //【LivChat】打开相册
            open_album()
            break
        case LFGlobalStrings.open_vibration:
            //【LivChat】震动
            open_vibration()
            break
        case LFGlobalStrings.request_camera_permission:
            //【LivChat】请求摄像头权限
            print("请求摄像头权限")
            request_camera_permission()
            break
        case LFGlobalStrings.request_microphone_permission:
            //【LivChat】请求麦克风权限
            print("请求麦克风权限")
            request_microphone_permission()
            break
        case LFGlobalStrings.web_log:
            print("WebLog: \(message.body as? String ?? "")")
            break
        default:
            break
        }
    }
    
    // MARK: - 调用原生方法（通用）
    /// 退出登录
    private func logout() {
        LFWebData.shared.clear_data()
    }
    
    /// 打开内置浏览器
    private func open_app_browser(url: URL, title: String = "") {
        let vc = LFWebController()
        vc.browserUrl = url.absoluteString
        vc.isNavigationBarHidden_ = false
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 打开外部浏览器
    private func open_external_browser(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /// 购买打点，实现Facebook、AppsFlyer、Firebase的购买日志逻辑
    /// - Parameter data: 打点数据
    private func log_purchase(data: [String: Any], log_type: PurchaseLogType) {
        // 实现Facebook、AppsFlyer、Firebase的购买日志逻辑
        guard let paidAmount = data[LFGlobalStrings.key_paid_amount] as? Double, let paidCurrency = data[LFGlobalStrings.key_paid_currency] as? String else {
            return
        }
        LFSdkStatistics.shared.purchase_record(paidAmount: paidAmount, paidCurrency: paidCurrency, log_type: log_type)
    }
    
    /// 内购
    /// - Parameter data: 下单数据
    private func open_in_app_purchase(data: [String: Any]) {
        guard let goods_code = data[LFGlobalStrings.key_goods_code] as? String else { return }
        let invitation_id = data[LFGlobalStrings.key_invitation_id] as? String ?? ""
        var pay_source = ""
        if (is_livchat_web) {
            pay_source = data[LFGlobalStrings.key_recharge_entry] as? String ?? ""
        } else {
            pay_source = data[LFGlobalStrings.key_goods_code] as? String ?? ""
        }
        
        var eventExtData: [String: Any] = [:]
        var broadcasterId: String = ""
        var scriptId: String = ""
        var routerPaths: [String] = []
        if let extData = data[LFGlobalStrings.key_event_ext_data] as? [String: Any] {
            eventExtData = extData
        }
        
        if let broadcaster_id = data[LFGlobalStrings.key_broadcaster_id] as? String {
            broadcasterId = broadcaster_id
        }
        
        if let script_id = data[LFGlobalStrings.key_script_id] as? String {
            scriptId = script_id
        }
        
        if let router_paths = data[LFGlobalStrings.key_event_path] as? [String] {
            routerPaths = router_paths
        }
        
        LFPurchaseManager.shared.buy(goods_code, paySource: pay_source, invitationId: invitation_id, eventExtData: eventExtData, broadcasterId: broadcasterId, scriptId: scriptId, routerPaths: routerPaths) { [weak self] succ in
            guard let self else { return }
            handlePurchase(success: succ, goodsCode: goods_code)
        }
    }
    
    /// 打开App评价
    private func open_app_store_review() {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            if let url = URL(string: String(format: LFGlobalStrings.review_url, LFAppConfig.app_id)) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    /// 设置禁止截屏和录屏
    /// - Parameter isDisabled: 是否禁用
    private func set_screen_capture_disabled(isDisabled: Bool) {
        isScreenCaptureDisabled = isDisabled
        //view.backgroundColor = isDisabled ? .black : .white
        guard let sview = view as? LFScreenShieldView else { return }
        sview.stextField?.isSecureTextEntry = isDisabled
    }
    
    /// 打开系统设置
    private func open_app_settings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    /// 设置禁止息屏
    /// - Parameter isEnabled: 是否可以息屏
    private func toggle_wake_lock(isEnabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = isEnabled
    }
        
    // MARK: - 调用H5方法（通用）
    /// 更新用户金币数量
    /// - Parameter coins: 目标金币
    private func update_coins(coins: Int) {
        self.webview.evaluateJavaScript(LFGlobalStrings.script_string_6) { response, error in }
    }
    
    /// 发送成功响应
    private func reply_success(to message: WKScriptMessage) {
        let script = LFGlobalStrings.script_string_7
        webview.evaluateJavaScript(script, completionHandler: nil)
    }
    
    // 处理前台事件
    @objc private func appDidBecomeActive() {
        print("App moved to foreground")
        let js_code = LFGlobalStrings.combine_js_code(LFGlobalStrings.app_lifecycle_state, data: LFGlobalStrings.js_data_1)
        // 调用 JS 通知前台状态
        webview.evaluateJavaScript(js_code) { result, error in
            if let error = error {
                print("Error executing JS: \(error.localizedDescription)")
            }
        }
    }
    
    // 处理后台事件
    @objc private func appDidEnterBackground() {
        print("App moved to background")
        let js_code = LFGlobalStrings.combine_js_code(LFGlobalStrings.app_lifecycle_state, data: LFGlobalStrings.js_data_2)
        // 调用 JS 通知后台状态
        webview.evaluateJavaScript(js_code) { result, error in
            if let error = error {
                print("Error executing JS: \(error.localizedDescription)")
            }
        }
    }
    
    // 截屏
    private func onScreenShotDetected() {
        let js_code = LFGlobalStrings.combine_js_code(
            LFGlobalStrings.on_screen_shot,
            data: LFGlobalStrings.js_data_3
        )
        
        webview.evaluateJavaScript(js_code) { result, error in
            if let error = error {
                print("JS Error: \(error.localizedDescription)")
            } else {
                print("onScreenShot event triggered.")
            }
        }
    }
    
    // 录屏
    private func onScreenCapture() {
        let isRecording = UIScreen.main.isCaptured
        let js_code = LFGlobalStrings.combine_js_code(
            LFGlobalStrings.on_capture,
            data: String(format: LFGlobalStrings.js_data_4, "\(isRecording)")
        )
        
        webview.evaluateJavaScript(js_code) { result, error in
            if let error = error {
                print("JS Error: \(error.localizedDescription)")
            } else {
                print("onCapture event triggered with value: \(isRecording).")
            }
        }
    }
    
    // 充值结果处理
    func handlePurchase(success: Bool, goodsCode: String) {
        // 构造 JS 脚本
        let js_code = LFGlobalStrings.combine_js_code(
            LFGlobalStrings.iap_result,
            data: String(format: LFGlobalStrings.js_data_5, "\(success)", goodsCode)
        )
        // 调用 WebView 的 JavaScript 方法
        webview.evaluateJavaScript(js_code) { result, error in
            if let error = error {
                print("JavaScript execution error: \(error.localizedDescription)")
            } else {
                print("JavaScript executed successfully: \(result ?? "No result")")
            }
        }
    }
}

// MARK: - 键盘扩展
extension LFWebController {
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        webview.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-keyboardHeight)
        }
        
        // 调整滚动区域
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: -keyboardHeight, right: 0)
        webview.scrollView.contentInset = insets
        webview.scrollView.scrollIndicatorInsets = insets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        webview.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        // 调整滚动区域
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        webview.scrollView.contentInset = insets
        webview.scrollView.scrollIndicatorInsets = insets
    }
}
