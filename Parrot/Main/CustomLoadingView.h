//
//  CustomLoadingView.h
//  Parrot
//
//  Created by WCF on 2025/9/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomLoadingView : NSObject
/**
 * 显示加载动画
 */
+ (void)show;

/**
 * 隐藏加载动画
 */
+ (void)hide;
@end

NS_ASSUME_NONNULL_END
