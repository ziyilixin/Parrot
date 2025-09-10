//
//  HealthDiagnosisView.h
//  Parrot
//
//  Created by WCF on 2025/9/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HealthDiagnosisViewDelegate <NSObject>
- (void)healthDiagnosisDidComplete;
@end

@interface HealthDiagnosisView : UIView

@property (nonatomic, weak) id<HealthDiagnosisViewDelegate> delegate;

- (void)refreshData;

@end

NS_ASSUME_NONNULL_END
