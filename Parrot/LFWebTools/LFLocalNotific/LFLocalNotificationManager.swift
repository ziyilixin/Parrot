import Foundation
import UserNotifications
import UIKit

class LFLocalNotificationManager: NSObject {
    
    static let shared = LFLocalNotificationManager()
    
    /// 保存已挂起的通知，用于后续动态挂起通知
    private var scheduled_notifications_key: String { LFGlobalStrings.key_scheduled_notifications }
    private var last_prompt_date_key: String { LFGlobalStrings.key_last_notification_prompt_date }
    /// 是否请求过通知权限，控制单次运行app仅请求一次通知权限
    private var has_requested_permission = false
    /// 是否完成初始化配置
    private var has_init = false
    /// 已经设置的通知
    private var scheduled_notifications: Set<String> = []
    
    private override init() {}
    
    static func init_config() {
        LFLocalNotificationManager.shared.requestNotificationPermission { granted in
            guard !LFLocalNotificationManager.shared.has_requested_permission else { return }
            LFLocalNotificationManager.shared.has_requested_permission = true
            
            if granted {
                LFLocalNotificationManager.shared.has_init = true
                
                // 设置通知中心代理
                UNUserNotificationCenter.current().delegate = LFLocalNotificationManager.shared
                
                // 检查并补充默认通知
                LFLocalNotificationManager.shared.setupDefaults()
                                
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    for request in requests {
                        print("挂起的通知: \(request.identifier), 内容: \(request.content.body)")
                    }
                }
                
                // 监听应用进入前台和后台
                NotificationCenter.default.addObserver(
                    LFLocalNotificationManager.shared,
                    selector: #selector(app_will_enter_foreground),
                    name: UIApplication.willEnterForegroundNotification,
                    object: nil
                )
                
                NotificationCenter.default.addObserver(
                    LFLocalNotificationManager.shared,
                    selector: #selector(app_did_enter_background),
                    name: UIApplication.didEnterBackgroundNotification,
                    object: nil
                )
                
            } else {
                // 提示用户去设置中开启权限
                LFLocalNotificationManager.shared.showSettingsAlert()
            }
        }
    }
    
    // 检查是否可以弹出通知权限提示框
    private func canShowPrompt() -> Bool {
        if let lastPromptDate = UserDefaults.standard.object(forKey: last_prompt_date_key) as? Date {
            let interval = Date().timeIntervalSince(lastPromptDate)
            // 2 天间隔（2 天 = 2 * 24 * 60 * 60 秒）
            return interval >= 2 * 24 * 60 * 60
        }
        return true // 第一次调用时允许弹出
    }
    
    private func showSettingsAlert(_ msg: String = "") {
        // 检查间隔条件
        guard canShowPrompt() else { return }
        UserDefaults.standard.set(Date(), forKey: last_prompt_date_key)
        
        let alert_ = UIAlertController(
            title: "\(LFGlobalStrings.enable_notifications) \(msg)",
            message: LFGlobalStrings.enable_notifications_desc,
            preferredStyle: .alert
        )
        
        // 添加 "Settings" 按钮
        alert_.addAction(UIAlertAction(title: LFGlobalStrings.s_settings, style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
            self.log_permission_alert(.settings)
        }))
        
        // 添加 "Cancel" 按钮
        alert_.addAction(UIAlertAction(title: LFGlobalStrings.s_cancel, style: .cancel, handler: { _ in
            self.log_permission_alert(.cancel)
        }))
        
        // 获取当前显示的顶层控制器并展示弹窗
        if let top_controller = UIApplication.shared.windows.first?.rootViewController {
            var presented_VC = top_controller
            while let next_vc = presented_VC.presentedViewController {
                presented_VC = next_vc
            }
            presented_VC.present(alert_, animated: true, completion: nil)
            self.log_permission_alert(.show)
        }
    }
    
    // 用于测试安装指定秒钟后弹本地通知
    func setupTestNotification(_ second: Int = 10) {
        let triggerDate = Calendar.current.date(byAdding: .second, value: second, to: Date())
        schedule_notification(
            id: LFGlobalStrings.test_notification,
            title: LFGlobalStrings.welcome_test,
            body: LFGlobalStrings.welcome_test_desc,
            date: triggerDate
        )
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        // 获取当前的通知权限状态
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                // 如果通知权限已经允许，就不再请求权限
                if settings.authorizationStatus == .authorized {
                    completion(true)
                    return
                }
                
                // 否则，继续请求权限
                self.log_permission(.request)
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    DispatchQueue.main.async {
                        if error != nil || !granted {
                            self.log_permission(.error)
                        }
                        completion(granted)
                    }
                }
            }
        }
    }
    
    // 进入前台时的处理
    @objc func app_will_enter_foreground() {
        setupDefaults()
    }

    // 进入后台时的处理
    @objc func app_did_enter_background() {
        setupDefaults()
    }
    
    // 每次启动时检测并补充默认的通知
    func setupDefaults(_ dev: Bool = false) {
        guard has_init else { return }
        
        // 每次启动都要清除原来挂起的通知，进行重置
        clear_all()
        
        // 获取当前日期
        let current_date = Date()
        
        let notifications_to_schedule = NotificationInterval.allCases
        
        for notification_ in notifications_to_schedule {
            // 如果通知未设置，则补充设置
            if !scheduled_notifications.contains(notification_.rawValue) {
                let trigger_date = Calendar.current.date(byAdding: dev ? .second : .day, value: notification_.days - 1, to: current_date)
                if let trigger_date = trigger_date, trigger_date > current_date {
//                    let image = LFNotificationImageManager.shared.getImage(named: notification_.imageName)
                    schedule_notification(
                        id: notification_.rawValue,
                        title: notification_.title,
                        body: notification_.message,
                        date: trigger_date,
                        // 可选图片地址，可以是网络地址，也可以是沙盒地址
                        imageUrlString: nil,
                        // 可选图片
                        image: nil
                    )
                    // 保存到已设置的通知集合
                    scheduled_notifications.insert(notification_.rawValue)
                }
            }
        }
    }
    
    func clear_all() {
        scheduled_notifications = []
        
        // 清除所有挂起的通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 清除通知栏的所有通知
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // 清除应用角标
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func schedule_notification(id: String, title: String, body: String, date: Date?, imageUrlString: String? = nil, image: UIImage? = nil) {
        guard let date = date else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        if let imageUrlString = imageUrlString, let attachment = createImageAttachment(from: imageUrlString) {
            content.attachments = [attachment]
        } else if let image = image, let attachment = createImageAttachment(from: image) {
            content.attachments = [attachment]
        }
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger_ = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger_)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func createImageAttachment(from imageUrlString: String) -> UNNotificationAttachment? {
        if imageUrlString.hasPrefix(LFGlobalStrings.key_http) {
            // 下载网络图片
            guard let imageUrl = URL(string: imageUrlString),
                  let imageData = try? Data(contentsOf: imageUrl),
                  let tempUrl = saveImageToTemporaryDirectory(data: imageData) else {
                return nil
            }
            return try? UNNotificationAttachment(identifier: UUID().uuidString, url: tempUrl, options: nil)
        } else {
            // 本地沙盒路径图片
            let fileUrl = URL(fileURLWithPath: imageUrlString)
            return try? UNNotificationAttachment(identifier: UUID().uuidString, url: fileUrl, options: nil)
        }
    }
    
    private func createImageAttachment(from image: UIImage, identifier: String = UUID().uuidString) -> UNNotificationAttachment? {
        // 将 UIImage 保存到临时目录
        guard let imageData = image.pngData(),
              let tempUrl = saveImageToTemporaryDirectory(data: imageData) else {
            return nil
        }
        
        // 创建 UNNotificationAttachment
        return try? UNNotificationAttachment(identifier: identifier, url: tempUrl, options: nil)
    }
    
    // 辅助方法：将图片数据保存到临时目录
    private func saveImageToTemporaryDirectory(data: Data) -> URL? {
        // 获取临时目录路径
        let tempDirectory = FileManager.default.temporaryDirectory
        let uniqueFileName = UUID().uuidString + ".png" // 使用唯一标识符生成文件名
        let tempUrl = tempDirectory.appendingPathComponent(uniqueFileName)
        
        // 保存数据到临时路径
        do {
            try data.write(to: tempUrl)
            return tempUrl
        } catch {
            print("Failed to save image to temporary directory: \(error)")
            return nil
        }
    }
}

extension LFLocalNotificationManager: UNUserNotificationCenterDelegate {
    // 处理通知点击事件（前台/后台均适用）
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 处理点击通知的逻辑
        LFLocalNotificationManager.shared.log_notify(.click)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let `self` = self else { return }
            showSettingsAlert("666")
        }
        completionHandler()
    }
}

// 通知的时间间隔枚举
enum NotificationInterval: String, CaseIterable {
    case days2 = "d2"
    case days3 = "d3"
    case days4 = "d4"
    case days7 = "d7"
    case days10 = "d10"
    case days13 = "d13"
    case days17 = "d17"
    case days20 = "d20"
    
    var days: Int {
        switch self {
        case .days2: return 2
        case .days3: return 3
        case .days4: return 4
        case .days7: return 7
        case .days10: return 10
        case .days13: return 13
        case .days17: return 17
        case .days20: return 20
        }
    }
    
    var title: String {
        switch self {
        case .days2: return LFGlobalStrings.day2_title
        case .days3: return LFGlobalStrings.day3_title
        case .days4: return LFGlobalStrings.day4_title
        case .days7: return LFGlobalStrings.day7_title
        case .days10: return LFGlobalStrings.day10_title
        case .days13: return LFGlobalStrings.day13_title
        case .days17: return LFGlobalStrings.day17_title
        case .days20: return LFGlobalStrings.day20_title
        }
    }
    
    var message: String {
        switch self {
        case .days2: return LFGlobalStrings.day2_message
        case .days3: return LFGlobalStrings.day3_message
        case .days4: return LFGlobalStrings.day4_message
        case .days7: return LFGlobalStrings.day7_message
        case .days10: return LFGlobalStrings.day10_message
        case .days13: return LFGlobalStrings.day13_message
        case .days17: return LFGlobalStrings.day17_message
        case .days20: return LFGlobalStrings.day20_message
        }
    }
    
//    var imageName: String {
//        switch self {
//        case .days2: return "days2_notify.png"
//        case .days3: return "days3_notify.png"
//        case .days4: return "days4_notify.png"
//        case .days7: return "days7_notify.png"
//        case .days10: return "days10_notify.png"
//        case .days13: return "days13_notify.png"
//        case .days17: return "days17_notify.png"
//        case .days20: return "days20_notify.png"
//        }
//    }
}

// MARK: - 日志
extension LFLocalNotificationManager {
    /// 通用日志统计方法，带重试逻辑
    private func log_event(
        _ name: String,
        parameters: [String: Any],
        renum: Int = 5,
        retryDelay: TimeInterval = 5
    ) {

    }
    
    /// 通知统计，action: set 设置本地通知 | click 点击通知进入
    func log_notify(_ action: LocNotifyction) {
        log_event(
            LFGlobalStrings.r_diversion_notify,
            parameters: [LFGlobalStrings.s_action: action.rawValue]
        )
    }
    
    /// 提示用户开启通知权限弹框，action: show 弹框显示 | settings 跳转设置 | cancel 取消
    func log_permission_alert(_ action: LocNotifyPermissionAlertAction) {
        log_event(
            LFGlobalStrings.r_diversion_notify_permission_alert,
            parameters: [LFGlobalStrings.s_action: action.rawValue]
        )
    }
    
    /// 请求用户通知权限弹框，action: request 请求权限 | error: 授权出错信息
    func log_permission(_ action: LocNotifyPermissionAction) {
        log_event(
            LFGlobalStrings.r_diversion_notify_permission,
            parameters: [LFGlobalStrings.s_action: action.rawValue]
        )
    }
}

/// 枚举类型
enum LocNotifyPermissionAction: String {
    case request, error
}

enum LocNotifyPermissionAlertAction: String {
    case show, settings, cancel
}

enum LocNotifyction: String {
    case set, click
}

