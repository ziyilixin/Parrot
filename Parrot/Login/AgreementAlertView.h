//
//  AgreementAlertView.h
//  NY
//
//  Created by WCF on 2025/5/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgreementAlertView : UIView
+ (void)showWithCompletion:(void(^)(BOOL agreed))completion;
@end

NS_ASSUME_NONNULL_END 
