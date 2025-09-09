//
//  NetworkPermissionManager.m
//  Parrot
//
//  Created by WCF on 2025/9/1.
//

#import "NetworkPermissionManager.h"
#import <Network/Network.h>
#import <CoreTelephony/CTCellularData.h>
#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "AFNetworking.h"

@implementation NetworkPermissionManager
+ (instancetype)sharedInstance {
    static NetworkPermissionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hasShownNetworkPermissionAlert = NO;
        self.hasNetworkPermission = NO;
        self.isCheckingNetworkPermission = NO;
    }
    return self;
}

- (void)checkNetworkPermissionWithCompletion:(NetworkPermissionCompletion)completion {
    if (self.isCheckingNetworkPermission) {
        return;
    }
    
    self.isCheckingNetworkPermission = YES;
    
    if (@available(iOS 13.0, *)) {
        #if TARGET_OS_SIMULATOR
        // 模拟器上直接假设有权限
        self.hasNetworkPermission = YES;
        completion(YES);
        #else
        // 真实设备上的原始代码
        CTCellularData *cellularData = [[CTCellularData alloc] init];
        cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isCheckingNetworkPermission = NO;
                switch (state) {
                    case kCTCellularDataRestrictedStateUnknown:
                        // 首次请求权限
                        [self requestNetworkPermissionWithCompletion:completion];
                        break;
                    case kCTCellularDataRestricted:
                        // 用户拒绝了权限
                        [self requestNetworkPermissionWithCompletion:completion];
                        break;
                    case kCTCellularDataNotRestricted:
                        // 用户允许了权限
                        self.hasNetworkPermission = YES;
                        completion(YES);
                        break;
                }
            });
        };
        #endif
    } else {
        // iOS 13以下默认有网络权限
        self.isCheckingNetworkPermission = NO;
        self.hasNetworkPermission = YES;
        completion(YES);
    }
}

- (void)requestNetworkPermissionWithCompletion:(NetworkPermissionCompletion)completion {
    // 触发系统权限弹窗
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.isCheckingNetworkPermission = YES;
    [manager GET:url.absoluteString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isCheckingNetworkPermission = NO;
            // 网络请求成功，用户允许了权限
            self.hasNetworkPermission = YES;
            completion(YES);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isCheckingNetworkPermission = NO;
            // 网络请求失败，可能是用户拒绝了权限
            self.hasNetworkPermission = NO;
            if (self.hasShownNetworkPermissionAlert) {
                // 已经显示过引导弹窗，直接回调
                completion(NO);
            } else {
                // 首次拒绝，不显示引导弹窗
                self.hasShownNetworkPermissionAlert = YES;
                completion(NO);
            }
        });
    }];
}

- (void)showNetworkPermissionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network permission"
                                                                 message:@"Please allow the application to use the network in the Settings"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Set up"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                         options:@{}
                               completionHandler:nil];
    }]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                              animated:YES
                                                                            completion:nil];
}
@end
