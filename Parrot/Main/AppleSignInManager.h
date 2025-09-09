#import <Foundation/Foundation.h>
#import <AuthenticationServices/AuthenticationServices.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 苹果登录状态
 */
typedef NS_ENUM(NSInteger, AppleSignInState) {
    AppleSignInStateSuccess,    // 登录成功
    AppleSignInStateFailed,     // 登录失败
    AppleSignInStateCancelled,  // 用户取消
    AppleSignInStateNotSupport  // 设备不支持
};

/**
 * 苹果登录回调
 * @param state 登录状态
 * @param identityToken token
 * @param email 用户邮箱（可能为空）
 * @param fullName 用户全名（可能为空）
 * @param error 错误信息（如果有）
 */
typedef void(^AppleSignInCompletion)(AppleSignInState state, NSString * _Nullable identityToken, NSString * _Nullable email, NSString * _Nullable fullName, NSError * _Nullable error);

/**
 * 苹果登录管理器
 * 使用单例模式管理苹果登录相关的操作
 */
@interface AppleSignInManager : NSObject

/**
 * 获取单例实例
 * @return AppleSignInManager单例
 */
+ (instancetype)sharedInstance;

/**
 * 检查设备是否支持苹果登录
 * @return 是否支持
 */
- (BOOL)isAppleSignInSupported;

/**
 * 处理苹果登录
 * @param completion 登录结果回调
 */
- (void)handleAppleSignInWithCompletion:(AppleSignInCompletion)completion;

/**
 * 处理苹果登录的回调URL
 * @param url 回调URL
 * @return 是否处理成功
 */
- (BOOL)handleOpenURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END 
