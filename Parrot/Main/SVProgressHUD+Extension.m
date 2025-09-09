//
//  SVProgressHUD+Extension.m
//  Massage
//
//  Created by WCF on 2021/5/13.
//

#import "SVProgressHUD+Extension.h"

static NSTimeInterval const kDefaultDuration = 1;//最短提示时间
static NSTimeInterval const kMaxDefaultDuration = 1.5;//最长提示时间

@implementation SVProgressHUD (Extension)
//正在加载
+ (void)showLoading {
    [self setMinimumDismissTimeInterval:kDefaultDuration];
    [self setDefaultStyle:SVProgressHUDStyleDark];
    [self setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [self show];
}

//加载成功
+ (void)showSuccess:(NSString *)success {
    [self setMinimumDismissTimeInterval:kDefaultDuration];
    [self setDefaultStyle:SVProgressHUDStyleDark];
    [self setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [self setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [self showSuccessWithStatus:success];
}

//加载失败
+ (void)showError:(NSString *)error {
    [self setMinimumDismissTimeInterval:kDefaultDuration];
    [self setDefaultStyle:SVProgressHUDStyleDark];
    [self setDefaultMaskType:SVProgressHUDMaskTypeNone];//提示期间用户不可操作
    [self setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [self showErrorWithStatus:error];
}

//提示信息
+ (void)showInfo:(NSString *)info {
    [self setMinimumDismissTimeInterval:kDefaultDuration];
    [self setMaximumDismissTimeInterval:kMaxDefaultDuration];
    [self setDefaultStyle:SVProgressHUDStyleDark];
    [self setDefaultMaskType:SVProgressHUDMaskTypeNone];//提示期间用户可操作
    [self setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [self showImage:[UIImage imageNamed:@""] status:info];
}

@end
