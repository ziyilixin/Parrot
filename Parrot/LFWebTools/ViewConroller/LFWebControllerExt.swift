import UIKit
import WebKit
import SwiftUI
import Photos

extension LFWebController {
    /// 【LivChat】打开文件选择器
    func open_file_browser() {
        // 创建文档选择器
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.content, .text, .image, .pdf, .audio, .video, .archive, .data])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        // 在 iPad 上需要设置弹出位置
        if let popoverController = documentPicker.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // 显示文档选择器
        present(documentPicker, animated: true, completion: nil)
    }
    
    /// 【LivChat】打开相册
    func open_album() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    /// 【LivChat】震动
    func open_vibration() {
        // 第一次振动180ms
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        // 500ms后执行第二次振动
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    /// 【LivChat】请求摄像头权限
    func request_camera_permission() {
        Task {
            // 请求摄像头权限
            let granted_ = await AVCaptureDevice.requestAccess(for: .video)
            // 构造 JS 脚本
            let js_code = LFGlobalStrings.combine_js_code(
                LFGlobalStrings.on_camera_permission,
                data: String(format: LFGlobalStrings.js_data_6, "\(granted_)")
            )
            // 主线程调用
            DispatchQueue.main.async { [weak self] in
                // 调用 WebView 的 JavaScript 方法
                self?.webview.evaluateJavaScript(js_code) { result, error in
                    if let error = error {
                        print("JavaScript execution error: \(error.localizedDescription)")
                    } else {
                        print("Camera permission callback executed successfully")
                    }
                }
            }
        }
    }
    
    /// 【LivChat】请求麦克风权限
    func request_microphone_permission() {
        Task {
            // 请求麦克风权限
            let granted_ = await AVCaptureDevice.requestAccess(for: .audio)
            // 构造 JS 脚本
            let js_code = LFGlobalStrings.combine_js_code(
                LFGlobalStrings.on_microphone_permission,
                data: String(format: LFGlobalStrings.js_data_6, "\(granted_)")
            )
            // 主线程调用
            DispatchQueue.main.async { [weak self] in
                // 调用 WebView 的 JavaScript 方法
                self?.webview.evaluateJavaScript(js_code) { result, error in
                    if let error = error {
                        print("JavaScript execution error: \(error.localizedDescription)")
                    } else {
                        print("Microphone permission callback executed successfully")
                    }
                }
            }
        }
    }
    
    // MARK: - 调用LivChat web方法
    /// 【LivChat】关闭当前页面
    func on_new_tpp_close() {
        // 构造 JS 脚本
        let js_code = LFGlobalStrings.combine_js_code(LFGlobalStrings.new_tpp_close, data: LFGlobalStrings.empty_js_data)
        // 调用 WebView 的 JavaScript 方法
        webview.evaluateJavaScript(js_code) { result, error in
            if let error = error {
                print("JavaScript execution error: \(error.localizedDescription)")
            } else {
                print("JavaScript executed successfully: \(result ?? "No result")")
            }
        }
    }
    
    ///【LivChat】打开客服私聊页
    func on_open_vip_service() {
        // 构造 JS 脚本
        let js_code = LFGlobalStrings.combine_js_code(LFGlobalStrings.open_vip_service, data: LFGlobalStrings.empty_js_data)
        // 调用 WebView 的 JavaScript 方法
        webview.evaluateJavaScript(js_code) { result, error in
            if let error = error {
                print("JavaScript execution error: \(error.localizedDescription)")
            } else {
                print("JavaScript executed successfully: \(result ?? "No result")")
            }
        }
    }
    
    ///【LivChat】打开充值页面
    func on_recharge() {
        // 构造 JS 脚本
        let js_code = LFGlobalStrings.combine_js_code(LFGlobalStrings.h5_recharge, data: LFGlobalStrings.empty_js_data)
        // 调用 WebView 的 JavaScript 方法
        webview.evaluateJavaScript(js_code) { result, error in
            if let error = error {
                print("JavaScript execution error: \(error.localizedDescription)")
            } else {
                print("JavaScript executed successfully: \(result ?? "No result")")
            }
        }
    }
    
    /// 【LivChat】选择图片
    func on_pick_image(_ file_info: [String: Any]) {
        guard let json_data = try? JSONSerialization.data(withJSONObject: file_info),
              let json_string = String(data: json_data, encoding: .utf8) else {
            return
        }
        // 构造 JS 脚本
        let js_code = LFGlobalStrings.combine_js_code(
            LFGlobalStrings.open_album,
            data: String(format: LFGlobalStrings.js_data_6, json_string)
        )
        // 调用 WebView 的 JavaScript 方法
        webview.evaluateJavaScript(js_code) { _, error in
            if let error_ = error {
                print("JavaScript execution error: \(error_.localizedDescription)")
            }
        }
    }
    
    /// 【LivChat】选择文件
    func on_pick_file(_ file_info: [String: Any]) {
        guard let json_data = try? JSONSerialization.data(withJSONObject: file_info),
              let json_string = String(data: json_data, encoding: .utf8) else {
            return
        }

        // 构造 JS 脚本
        let js_code = LFGlobalStrings.combine_js_code(
            LFGlobalStrings.open_file_browser,
            data: String(format: LFGlobalStrings.js_data_6, json_string)
        )
        // 调用 WebView 的 JavaScript 方法
        webview.evaluateJavaScript(js_code) { _, error in
            if let error = error {
                print("JavaScript execution error: \(error.localizedDescription)")
            } else {
                print("File info sent to JavaScript successfully")
            }
        }
    }
}

extension LFWebController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        // 获取选中的图片
        guard let image_ = info[.originalImage] as? UIImage,
              let image_data_ = image_.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // 将图片数据转换为base64
        let base64_string_ = image_data_.base64EncodedString()
        
        // 保存图片到临时目录
        let file_name_ = "\(UUID().uuidString).\(LFGlobalStrings.key_jpg)"
        let temp_path_ = FileManager.default.temporaryDirectory.appendingPathComponent(file_name_)
        
        do {
            try image_data_.write(to: temp_path_)
            
            // 创建文件信息字典
            let file_info_: [String: Any] = [
                LFGlobalStrings.key_name: file_name_,
                LFGlobalStrings.key_size: image_data_.count,
                LFGlobalStrings.key_extension: LFGlobalStrings.key_jpg,
                LFGlobalStrings.key_mime_type: LFGlobalStrings.key_image_jpeg,
                LFGlobalStrings.key_path: temp_path_.path,
                LFGlobalStrings.key_base64: base64_string_
            ]
            
            // 发送文件信息到 JavaScript
            on_pick_image(file_info_)
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


extension LFWebController: UIDocumentPickerDelegate {
    @objc func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        // 获取文件信息
        let fileName = selectedFileURL.lastPathComponent
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: selectedFileURL.path)[.size] as? Int64) ?? 0
        let fileExtension = selectedFileURL.pathExtension
        
        // 获取文件MIME类型
        let mimeType: String
        if let utType = try? selectedFileURL.resourceValues(forKeys: [.contentTypeKey]).contentType {
            mimeType = utType.preferredMIMEType ?? LFGlobalStrings.mime_type
        } else {
            mimeType = LFGlobalStrings.mime_type
        }
        
        // 创建文件信息字典
        let file_info: [String: Any] = [
            LFGlobalStrings.key_name: fileName,
            LFGlobalStrings.key_size: fileSize,
            LFGlobalStrings.key_extension: fileExtension,
            LFGlobalStrings.key_mime_type: mimeType,
            LFGlobalStrings.key_path: selectedFileURL.path
        ]
        
        document_file(file_url: selectedFileURL, file_info: file_info)
    }
    
    func document_file(file_url: URL, file_info: [String: Any]) {
        let authozied = file_url.startAccessingSecurityScopedResource()
        if authozied {
            // 通过文件协调器读取文件地址
            let fileCoordinator = NSFileCoordinator()
            fileCoordinator.coordinate(readingItemAt: file_url, options: [.withoutChanges], error: nil) { url in
                let is_exist = FileManager.default.fileExists(atPath: url.path)
                if is_exist {
                    // 将文件缓存在沙盒
                    let data = try? Data(contentsOf: url)
                    let file_name = url.lastPathComponent
                    let new_path = FileManager.default.temporaryDirectory.appendingPathComponent(file_name)
                    try? data?.write(to: new_path)
                    let is_exist_2 = FileManager.default.fileExists(atPath: new_path.path)
                    guard is_exist_2 else {
                        return
                    }
                    
                    // 发送文件信息到 JavaScript
                    on_pick_file(file_info)
                }
            }
        }
        // 停止安全访问权限
        file_url.stopAccessingSecurityScopedResource()
        
    }
    
    @objc func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
    }
}
