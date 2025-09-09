import Foundation
import UIKit

class SafeAreaTool {
    /// 获取顶部安全区域高度
    static var safe_top: CGFloat {
        if #available(iOS 15.0, *) {
            guard let window_scene_ = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window_ = window_scene_.windows.first else {
                return 0
            }
            return window_.safeAreaInsets.top
        } else {
            guard let window_ = UIApplication.shared.windows.first else {
                return 0
            }
            return window_.safeAreaInsets.top
        }
    }
    
    /// 获取底部安全区域高度
    static var safe_bottom: CGFloat {
        if #available(iOS 15.0, *) {
            guard let window_scene_ = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window_ = window_scene_.windows.first else {
                return 0
            }
            return window_.safeAreaInsets.bottom
        } else {
            guard let window_ = UIApplication.shared.windows.first else {
                return 0
            }
            return window_.safeAreaInsets.bottom
        }
    }
}
