//
//  UserViewModel.swift
//  WebTest
//
//  Created by dayu on 2025/5/21.
//

import Foundation

class UserViewModel {
    // MARK: - 单例实现
    static let shared = UserViewModel()
    
    // 私有初始化器，防止外部实例化
    private init() {
        // 初始化代码
        user_id = ""
        setup()
    }
    
    // MARK: - 公共属性和方法
//    var currentUser: User?
    var user_id:String
    
    func logout() {
        // 获取用户详情的逻辑
    }
    
    // MARK: - 私有方法
    private func setup() {
        // 单例初始化时的设置逻辑
    }
}
