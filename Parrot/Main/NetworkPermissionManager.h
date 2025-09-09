//
//  NetworkPermissionManager.h
//  Parrot
//
//  Created by WCF on 2025/9/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NetworkPermissionCompletion)(BOOL granted);

@interface NetworkPermissionManager : NSObject
+ (instancetype)sharedInstance;

/**
 * 检查网络权限
 */
- (void)checkNetworkPermissionWithCompletion:(NetworkPermissionCompletion)completion;

/**
 * 显示网络权限引导弹窗
 */
- (void)showNetworkPermissionAlert;

/**
 * 是否已经显示过网络权限引导弹窗
 */
@property (nonatomic, assign) BOOL hasShownNetworkPermissionAlert;

/**
 * 是否已获得网络权限
 */
@property (nonatomic, assign) BOOL hasNetworkPermission;

/**
 * 是否正在检查网络权限
 */
@property (nonatomic, assign) BOOL isCheckingNetworkPermission;
@end

NS_ASSUME_NONNULL_END
