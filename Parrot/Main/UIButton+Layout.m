//
//  UIButton+Layout.m
//  Massage
//
//  Created by WCF on 2021/5/13.
//

#import "UIButton+Layout.h"

@implementation UIButton (Layout)
/**
 *  水平居中按钮 image 和 title
 *
 *  @param spacing - image 和 title 的水平间距, 单位point
 */
- (void)horizontalCenterImageAndTitleWithSpacing:(float)spacing
{
    //left the image
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, -spacing, 0.0, 0.0);
    
    //right the text
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -spacing);
}

/**
 *  水平居中按钮 title 和 image
 *
 *  @param spacing - image 和 title 的水平间距, 单位point
 */
- (void)horizontalCenterTitleAndImageWithSpacing:(float)spacing
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = [self.titleLabel.text boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
    
    CGFloat totalWidth = imageSize.width + titleSize.width + spacing;
    
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -(totalWidth - imageSize.width) * 2);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -(totalWidth - titleSize.width) * 2, 0.0, 0.0);
}

/**
 *  垂直居中按钮 image 和 title
 *
 *  @param spacing - image 和 title 的垂直间距, 单位point
 */
- (void)verticalCenterImageAndTitleWithSpacing:(float)spacing
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = [self.titleLabel.text boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
    CGFloat totalHeight = imageSize.height + titleSize.height + spacing;
    
    self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), 0.0, 0.0, -titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(totalHeight - titleSize.height), 0.0);
}
@end
