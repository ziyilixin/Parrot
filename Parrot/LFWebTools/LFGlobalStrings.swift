import Foundation

struct LFGlobalStrings {
    
    
    /// 退出登录
    /// Logout
    static let logout = StringDecrypt.Decrypt(.logout)
    /// 打开应用内浏览器
    /// OpenAppBrowser
    static let open_app_browser = StringDecrypt.Decrypt(.open_app_browser)
    
    /// 打开外部浏览器
    /// OpenLink
    static let open_link = StringDecrypt.Decrypt(.open_link)
    
    /// 购买记录
    /// LogPurchaseForFB
    static let log_purchase_fb = StringDecrypt.Decrypt(.log_purchase_fb)
    
    /// 购买记录
    /// LogPurchaseForAppsFlyer
    static let log_purchase_apps = StringDecrypt.Decrypt(.log_purchase_apps)
    
    /// 购买记录
    /// LogFirebasePurchase
    static let log_purchase_firebase = StringDecrypt.Decrypt(.log_purchase_firebase)
    
    /// 原生支付
    /// OpenAppPurchase
    static let open_app_purchase = StringDecrypt.Decrypt(.open_app_purchase)
    
    /// App评价弹窗
    /// OpenAppStoreReview
    static let open_app_store_review = StringDecrypt.Decrypt(.open_app_store_review)
    
    /// 禁止截屏、录屏
    /// SetScreenCaptureDisabled
    static let set_screen_capture_disabled = StringDecrypt.Decrypt(.set_screen_capture_disabled)
    
    /// 打开应用设置
    /// OpenAppSettings
    static let open_app_settings = StringDecrypt.Decrypt(.open_app_settings)
    
    /// 禁止息屏
    /// Wakelock
    static let screen_wakelock = StringDecrypt.Decrypt(.screen_wakelock)
    
    /// 更新金币
    /// UpdateCoins
    static let update_coins = StringDecrypt.Decrypt(.update_coins)
    
    /// 关闭当前页面
    /// newTppClose
    static let new_tpp_close = StringDecrypt.Decrypt(.new_tpp_close)
    
    /// 打开客服私聊页
    /// openVipService
    static let open_vip_service = StringDecrypt.Decrypt(.open_vip_service)
    
    /// 打开充值页面
    /// recharge
    static let h5_recharge = StringDecrypt.Decrypt(.h5_recharge)
    
    /// 允许侧滑返回手势
    /// AllowsBackForwardNavigationGestures
    static let allows_back_forward_navigation_gestures = StringDecrypt.Decrypt(.allows_back_forward_navigation_gestures)
    
    /// 记录Firebase事件
    /// LogFirebaseEvent
    static let log_firebase_event = StringDecrypt.Decrypt(.log_firebase_event)
    
    /// 购买记录
    /// LogPurchaseForAJ
    static let log_purchase_aj = StringDecrypt.Decrypt(.log_purchase_aj)
    
    /// 打开H5浏览器
    /// OpenH5Browser
    static let open_h5_browser = StringDecrypt.Decrypt(.open_h5_browser)
    
    /// 打开文件浏览器
    /// OpenFileBrowser
    static let open_file_browser = StringDecrypt.Decrypt(.open_file_browser)
    
    /// 打开相册
    /// OpenAlbum
    static let open_album = StringDecrypt.Decrypt(.open_album)
    
    /// 打开震动
    /// OpenVibration
    static let open_vibration = StringDecrypt.Decrypt(.open_vibration)
    
    /// 请求相机权限
    /// RequestCameraPermission
    static let request_camera_permission = StringDecrypt.Decrypt(.request_camera_permission)
    
    /// 请求麦克风权限
    /// RequestMicrophonePermission
    static let request_microphone_permission = StringDecrypt.Decrypt(.request_microphone_permission)
    
    /// web日志
    /// WebLog
    static let web_log = StringDecrypt.Decrypt(.web_log)
    
    /// newTppLogEvent（特殊）
    static let new_tpp_log_event = StringDecrypt.Decrypt(.new_tpp_log_event)
    
    /// 充值来源（特殊）
    /// rechargeSource
    static let recharge_source = StringDecrypt.Decrypt(.recharge_source)
    
    /// 内购购买结果（特殊）
    /// purchase
    static let iap_result = StringDecrypt.Decrypt(.iap_result)
    
    /// App生命周期状态（特殊）
    /// AppLifecycleState
    static let app_lifecycle_state = StringDecrypt.Decrypt(.app_lifecycle_state)
    
    /// 截屏状态（特殊）
    /// onScreenShot
    static let on_screen_shot = StringDecrypt.Decrypt(.on_screen_shot)
    
    /// 录屏状态（特殊）
    /// onCapture
    static let on_capture = StringDecrypt.Decrypt(.on_capture)
    
    /// 相机权限状态（特殊）
    /// onCameraPermission
    static let on_camera_permission = StringDecrypt.Decrypt(.on_camera_permission)
    
    /// 麦克风权限状态（特殊）
    /// onMicrophonePermission
    static let on_microphone_permission = StringDecrypt.Decrypt(.on_microphone_permission)
    
    /// WebvView加载进度
    /// estimatedProgress
    static let estimated_progress = StringDecrypt.Decrypt(.estimated_progress)
    
    /// 打开客服私聊页通知
    /// open_customer_service
    static let open_customer_service_noti = StringDecrypt.Decrypt(.open_customer_service_noti)
    
    /// 文件类型字符串 MIME
    /// "application/octet-stream"
    static let mime_type = StringDecrypt.Decrypt(.mime_type)
    
    /// 灵峰客服私聊页
    /// "%@#/pages/chat/chat?userId=%@"
    static let lf_chat_url = StringDecrypt.Decrypt(.lf_chat_url)
    
    /// 灵蜂充值页
    /// "%@#/pages/app-coin-store-dialog/app-coin-store-dialog"
    static let lf_recharge_url = StringDecrypt.Decrypt(.lf_recharge_url)
    
    /// App评价url
    /// "https://apps.apple.com/app/id%@?action=write-review"
    static let review_url = StringDecrypt.Decrypt(.review_url)
    
    /// JS脚本字符串1
    /// window.appConfigOptions = JSON.parse('%@');
    static let script_string_1 = StringDecrypt.Decrypt(.script_string_1)
    
    /// JS脚本字符串2
    /// document.body.style.backgroundColor = '#1E1A32';
    static let script_string_2 = StringDecrypt.Decrypt(.script_string_2)
    
    /// appId
    static let key_app_id = StringDecrypt.Decrypt(.apId)
        
    /// 主播墙id
    static let key_broadcaster_id = StringDecrypt.Decrypt(.bsId)
        
    /// 话术id
    static let key_script_id = StringDecrypt.Decrypt(.scId)
        
    /// eventExtData
    static let key_event_ext_data = StringDecrypt.Decrypt(.exId)
        
    /// 路由路径
    static let key_event_path = StringDecrypt.Decrypt(.evP)
    
    /// JS脚本字符串3
    /// "%@:(arg)=>{%@.postMessage(typeof arg==\"object\" ? JSON.stringify( arg || {} ) : (arg || \"\") ) },"
    static let script_string_3 = StringDecrypt.Decrypt(.script_string_3)
    
    /// JS脚本字符串4
    /// "window.JSBridgeService = {%@};"
    static let script_string_4 = StringDecrypt.Decrypt(.script_string_4)
    
    /// JS脚本字符串5
    /// window.webkit.messageHandlers.AllowsBackForwardNavigationGestures.postMessage('success');
    static let script_string_5 = StringDecrypt.Decrypt(.script_string_5)
    
    /// JS脚本字符串6
    /// "HttpTool.NativeToJs('recharge')"
    static let script_string_6 = StringDecrypt.Decrypt(.script_string_6)
    
    /// JS脚本字符串7
    /// "window.postMessage({data: 'success'}, '*');"
    static let script_string_7 = StringDecrypt.Decrypt(.script_string_7)
    
    /// 通用JS代码
    ///  "window.dispatchEvent(new CustomEvent('%@', %@))"
    static let common_js_code = StringDecrypt.Decrypt(.common_js_code)
    
    /// 空JS Data
    /// "{ detail: JSON.stringify({ }) }"
    static let empty_js_data = StringDecrypt.Decrypt(.empty_js_data)
    
    /// JS Data1
    /// "{ detail: {result: 'resumed'}}"
    static let js_data_1 = StringDecrypt.Decrypt(.js_data_1)
    
    /// JS Data2
    /// "{ detail: {result: 'paused'}}"
    static let js_data_2 = StringDecrypt.Decrypt(.js_data_2)
    
    /// JS Data3
    /// "{ detail: JSON.stringify({ data: true }) }"
    static let js_data_3 = StringDecrypt.Decrypt(.js_data_3)
    
    /// JS Data4
    /// "{ detail: JSON.stringify({ data: %@ }) }"
    static let js_data_4 = StringDecrypt.Decrypt(.js_data_4)
    
    /// JS Data5
    /// "{ detail: JSON.stringify({ success: %@, data: { goodsCode: '%@' } }) }"
    static let js_data_5 = StringDecrypt.Decrypt(.js_data_5)
    
    /// JS Data6
    /// "{ detail: %@ }"
    static let js_data_6 = StringDecrypt.Decrypt(.js_data_6)
    
    /// http_headers
    static let key_http_headers = StringDecrypt.Decrypt(.key_http_headers)
    
    /// appBaseUrl
    static let key_app_base_url = StringDecrypt.Decrypt(.key_app_base_url)
    
    /// h5
    static let key_h5 = StringDecrypt.Decrypt(.key_h5)
    
    /// app
    static let key_app = StringDecrypt.Decrypt(.key_app)
    
    /// im
    static let key_im = StringDecrypt.Decrypt(.key_im)
    
    /// log
    static let key_log = StringDecrypt.Decrypt(.key_log)
    
    /// privacyLink
    static let key_privacy_link = StringDecrypt.Decrypt(.key_privacy_link)
    
    /// termsLink
    static let key_terms_link = StringDecrypt.Decrypt(.key_terms_link)
    
    /// bearer
    static let key_bearer = StringDecrypt.Decrypt(.key_bearer)
    
    /// iOS-WKWebView
    static let value_bearer = StringDecrypt.Decrypt(.value_bearer)
    
    /// appPackageInfo
    static let key_app_package_info = StringDecrypt.Decrypt(.key_app_package_info)
    
    /// lanId
    static let key_lan_id = StringDecrypt.Decrypt(.key_lan_id)
    
    /// appName
    static let key_app_name = StringDecrypt.Decrypt(.key_app_name)
    
    /// packageName
    static let key_package_name = StringDecrypt.Decrypt(.key_package_name)
    
    /// appIconUrl
    static let key_app_icon_url = StringDecrypt.Decrypt(.key_app_icon_url)
    
    /// isDebug
    static let key_is_debug = StringDecrypt.Decrypt(.key_is_debug)
    
    /// appConfigData
    static let key_app_config_data = StringDecrypt.Decrypt(.key_app_config_data)
    
    /// strategyData
    static let key_strategy_data = StringDecrypt.Decrypt(.key_strategy_data)
    
    /// userInfo
    static let key_user_info = StringDecrypt.Decrypt(.key_user_info)
    
    /// safe_area_top
    static let key_safe_area_top = StringDecrypt.Decrypt(.key_safe_area_top)
    
    /// safe_area_bottom
    static let key_safe_area_bottom = StringDecrypt.Decrypt(.key_safe_area_bottom)
    
    /// bind_invitation_code
    static let key_bind_invitation_code = StringDecrypt.Decrypt(.key_bind_invitation_code)
    
    /// url
    static let key_url = StringDecrypt.Decrypt(.key_url)
    
    /// title
    static let key_title = StringDecrypt.Decrypt(.key_title)
    
    /// paidAmount
    static let key_paid_amount = StringDecrypt.Decrypt(.key_paid_amount)
    
    /// paidCurrency
    static let key_paid_currency = StringDecrypt.Decrypt(.key_paid_currency)
    
    /// goodsCode
    static let key_goods_code = StringDecrypt.Decrypt(.key_goods_code)
    
    /// invitationId
    static let key_invitation_id = StringDecrypt.Decrypt(.key_invitation_id)
    
    /// rechargeEntry
    static let key_recharge_entry = StringDecrypt.Decrypt(.key_recharge_entry)
    
    /// name
    static let key_name = StringDecrypt.Decrypt(.key_name)
    
    /// size
    static let key_size = StringDecrypt.Decrypt(.key_size)
    
    /// extension
    static let key_extension = StringDecrypt.Decrypt(.key_extension)
    
    /// mimeType
    static let key_mime_type = StringDecrypt.Decrypt(.key_mime_type)
    
    /// path
    static let key_path = StringDecrypt.Decrypt(.key_path)
    
    /// base64
    static let key_base64 = StringDecrypt.Decrypt(.key_base64)
    
    /// jpg
    static let key_jpg = StringDecrypt.Decrypt(.key_jpg)
    
    /// image/jpeg
    static let key_image_jpeg = StringDecrypt.Decrypt(.key_image_jpeg)
    
    /// chevron.left
    static let key_chevron_left = StringDecrypt.Decrypt(.key_chevron_left)
    
    /// CFBundleDisplayName
    static let key_cf_bundle_display_name = StringDecrypt.Decrypt(.key_cf_bundle_display_name)
    
    /// CFBundleName
    static let key_cf_bundle_name = StringDecrypt.Decrypt(.key_cf_bundle_name)
    
    /// true
    static let key_true = StringDecrypt.Decrypt(.key_true)
    
    /// false
    static let key_false = StringDecrypt.Decrypt(.key_false)
    
    /// http
    static let key_http = StringDecrypt.Decrypt(.key_http)
    
    /// https
    static let key_https = StringDecrypt.Decrypt(.key_https)
    
    /// attribution_sdk
    static let key_attribution_sdk = StringDecrypt.Decrypt(.key_attribution_sdk)
    
    /// scheduled_notifications
    static let key_scheduled_notifications = StringDecrypt.Decrypt(.key_scheduled_notifications)
    
    /// LastNotificationPromptDate
    static let key_last_notification_prompt_date = StringDecrypt.Decrypt(.key_last_notification_prompt_date)
    
    /// Apple Pay is not available
    static let apple_pay_not_available = StringDecrypt.Decrypt(.apple_pay_not_available)
    
    /// The transaction voucher is empty
    static let transaction_voucher_empty = StringDecrypt.Decrypt(.transaction_voucher_empty)
    
    /// verify fail
    static let verify_fail = StringDecrypt.Decrypt(.verify_fail)
    
    /// Purchase Failure
    static let purchase_failure = StringDecrypt.Decrypt(.purchase_failure)
    
    /// Purchase cancel
    static let purchase_cancel = StringDecrypt.Decrypt(.purchase_cancel)
    
    /// There is no relevant product in the app store
    static let no_relevant_product = StringDecrypt.Decrypt(.no_relevant_product)
    
    /// purchase_success
    static let purchase_success = StringDecrypt.Decrypt(.purchase_success)
    
    /// Enable Notifications
    static let enable_notifications = StringDecrypt.Decrypt(.enable_notifications)
    
    /// For a better user experience, please enable notification permissions in Settings.
    static let enable_notifications_desc = StringDecrypt.Decrypt(.enable_notifications_desc)
    
    /// Settings
    static let s_settings = StringDecrypt.Decrypt(.s_settings)
    
    /// Cancel
    static let s_cancel = StringDecrypt.Decrypt(.s_cancel)
    
    /// test_notification
    static let test_notification = StringDecrypt.Decrypt(.test_notification)
    
    /// Welcome Test
    static let welcome_test = StringDecrypt.Decrypt(.welcome_test)
    
    /// Welcome! Thank you for installing the app. Explore now and enjoy the fun!
    static let welcome_test_desc = StringDecrypt.Decrypt(.welcome_test_desc)
    
    /// I miss your strength🔥🔥🔥.
    static let day2_title = StringDecrypt.Decrypt(.day2_title)
    
    /// Baby, I miss you💋💋💋.
    static let day3_title = StringDecrypt.Decrypt(.day3_title)
    
    /// Many beautiful girls send you messages.
    static let day4_title = StringDecrypt.Decrypt(.day4_title)
    
    /// 🔥🔥🔥There are so many fun things to discover!
    static let day7_title = StringDecrypt.Decrypt(.day7_title)
    
    /// 🎁🎁🎁Lots of rewards coming!
    static let day10_title = StringDecrypt.Decrypt(.day10_title)
    
    /// Claim Your Ultimate Power Pack!
    static let day13_title = StringDecrypt.Decrypt(.day13_title)
    
    /// 🔥🔥🔥Discover excitement with sexy hosts!
    static let day17_title = StringDecrypt.Decrypt(.day17_title)
    
    /// 🔥🔥🔥Reignite the passion moment!
    static let day20_title = StringDecrypt.Decrypt(.day20_title)
    
    /// I really want to do some interesting and exciting things with you[💦][💦][💦].
    static let day2_message = StringDecrypt.Decrypt(.day2_message)
    
    /// I sent you a lot of messages. Come and have a look.
    static let day3_message = StringDecrypt.Decrypt(.day3_message)
    
    /// 🔥🔥🔥Come and chat with them and share interesting stories.
    static let day4_message = StringDecrypt.Decrypt(.day4_message)
    
    /// 🌶️🌶️🌶️There are many hot new anchors, come and play together!
    static let day7_message = StringDecrypt.Decrypt(.day7_message)
    
    /// 💰💰💰Large rewards are being distributed, go and claim them now.
    static let day10_message = StringDecrypt.Decrypt(.day10_message)
    
    /// 🔥🔥🔥For real men — tap now to dominate!
    static let day13_message = StringDecrypt.Decrypt(.day13_message)
    
    /// 💋💋💋Real men, real excitement - enjoy the ultimate experience!
    static let day17_message = StringDecrypt.Decrypt(.day17_message)
    
    /// 🌶️🌶️🌶️ Super value rewards + big discounts, men need passion!
    static let day20_message = StringDecrypt.Decrypt(.day20_message)
    
    /// r_diversion_notify
    static let r_diversion_notify = StringDecrypt.Decrypt(.r_diversion_notify)
    
    /// r_diversion_notify_permission_alert
    static let r_diversion_notify_permission_alert = StringDecrypt.Decrypt(.r_diversion_notify_permission_alert)
    
    /// r_diversion_notify_permission
    static let r_diversion_notify_permission = StringDecrypt.Decrypt(.r_diversion_notify_permission)

    /// action
    static let s_action = StringDecrypt.Decrypt(.s_action)
    
    /// JS事件
    static var all_js_event: [String] {
        [
            logout,
            open_app_browser,
            open_link,
            log_purchase_fb,
            log_purchase_apps,
            log_purchase_firebase,
            open_app_purchase,
            open_app_store_review,
            set_screen_capture_disabled,
            open_app_settings,
            screen_wakelock,
            update_coins,
            new_tpp_close,
            open_vip_service,
            h5_recharge,
            allows_back_forward_navigation_gestures,
            log_firebase_event,
            log_purchase_aj,
            open_h5_browser,
            open_file_browser,
            open_album,
            open_vibration,
            request_camera_permission,
            request_microphone_permission,
            web_log
        ]
    }
    
    /// 组合JS代码
    static func combine_js_code(_ event_name: String, data: String) -> String {
        String(format: common_js_code, event_name, data)
    }
}
