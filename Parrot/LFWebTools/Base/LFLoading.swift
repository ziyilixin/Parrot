//
//  LFLoading.swift
//  Santai
//
//  Created by Giftic on 2024/11/19.
//

import UIKit

final class LFLoading {

    // MARK: - Singleton
    static let shared = LFLoading()
    private init() {}

    // MARK: - Properties
    private lazy var overlayView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true // 禁止底层交互
        return view
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    private var isLoading: Bool = false

    // MARK: - Methods
    func show() {
        DispatchQueue.main.async {
            self.mainshow()
        }
    }
    
    private func mainshow() {
        guard let key_window = UIApplication.shared.keyWindow, !isLoading else { return }

        isLoading = true

        // 配置 overlayView
        overlayView.frame = key_window.bounds

        // 配置 activityIndicator
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)

        // 配置 messageLabel
        messageLabel.isHidden = true
        overlayView.addSubview(messageLabel)

        // 添加到窗口
        key_window.addSubview(overlayView)

        // 开始动画
        activityIndicator.startAnimating()
    }

    func hide() {
        DispatchQueue.main.async {
            self.mainhide()
        }
    }
    
    private func mainhide() {
        guard isLoading else { return }

        isLoading = false
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }

    func showMessage(_ message: String, duration: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            self.mainshowMessage(message, duration: duration)
        }
    }
    
    private func mainshowMessage(_ message: String, duration: TimeInterval = 2.0) {
        guard let key_window = UIApplication.shared.keyWindow else { return }
        
        // 隐藏加载动画
        mainhide()
        
        // 配置 messageLabel
        self.messageLabel.text = message
        self.messageLabel.isHidden = false
        let labelSize = CGSize(width: key_window.bounds.width * 0.8, height: CGFloat.greatestFiniteMagnitude)
        let textRect = self.messageLabel.sizeThatFits(labelSize)
        self.messageLabel.frame = CGRect(
            x: (key_window.bounds.width - textRect.width - 20) / 2,
            y: key_window.bounds.height / 2,
            width: textRect.width + 20,
            height: textRect.height + 20
        )
        
        // 添加到窗口
        self.overlayView.frame = key_window.bounds
        self.overlayView.addSubview(self.messageLabel)
        key_window.addSubview(self.overlayView)
        // 延迟自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.overlayView.removeFromSuperview()
            self?.messageLabel.isHidden = true
        }
    }
    
    static func show() {
        LFLoading.shared.show()
    }
    
    static func hide() {
        LFLoading.shared.hide()
    }
    
    static func showMessage(_ message: String, duration: TimeInterval = 2.0) {
        LFLoading.shared.showMessage(message, duration: duration)
    }
    
}
