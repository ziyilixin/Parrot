//
//  UIButton+Layout.h
//  Massage
//
//  Created by WCF on 2021/5/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Layout)
/**
 *  水平居中按钮 image 和 title
 *
 *  @param spacing - image 和 title 的水平间距, 单位point
 */
- (void)horizontalCenterImageAndTitleWithSpacing:(float)spacing;

/**
 *  水平居中按钮 title 和 image
 *
 *  @param spacing - image 和 title 的水平间距, 单位point
 */
- (void)horizontalCenterTitleAndImageWithSpacing:(float)spacing;

/**
 *  垂直居中按钮 image 和 title
 *
 *  @param spacing - image 和 title 的垂直间距, 单位point
 */
- (void)verticalCenterImageAndTitleWithSpacing:(float)spacing;
@end

NS_ASSUME_NONNULL_END
