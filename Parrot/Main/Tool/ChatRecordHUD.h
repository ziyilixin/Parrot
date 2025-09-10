//
//  ChatRecordHUD.h
//  Kovela
//
//  Created by WCF on 2025/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatRecordHUD : UIView
- (void)showInView:(UIView *)view;
- (void)dismiss;
- (void)updateDuration:(NSTimeInterval)duration;
- (void)setOnTapEnd:(void (^)(void))onTapEnd;
@end

NS_ASSUME_NONNULL_END
