//
//  SVProgressHUD+Extension.h
//  Massage
//
//  Created by WCF on 2021/5/13.
//

#import "SVProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface SVProgressHUD (Extension)
//正在加载
+ (void)showLoading;

//加载成功
+ (void)showSuccess:(NSString *)success;

//加载失败
+ (void)showError:(NSString *)error;

//提示信息
+ (void)showInfo:(NSString *)info;
@end

NS_ASSUME_NONNULL_END
