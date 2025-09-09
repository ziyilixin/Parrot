import SwiftUI
import WebKit

struct LFWebControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        // 创建ViewController
        let view_controller = LFWebController()
        view_controller.isProgressHidden = is_livchat_web
        // 创建导航控制器
        let nav_controller = WebNavigationController(rootViewController: view_controller)
        return nav_controller
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UINavigationController
}

/// 【LivChat】新增
class WebNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
