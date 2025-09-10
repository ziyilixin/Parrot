//
//  DiagnosisDetailViewController.h
//  Parrot
//
//  Created by AI Assistant on 2025/09/10.
//

#import <UIKit/UIKit.h>

@class DiagnosisRecord;

NS_ASSUME_NONNULL_BEGIN

@interface DiagnosisDetailViewController : UIViewController

@property (nonatomic, strong) DiagnosisRecord *record;

- (instancetype)initWithDiagnosisRecord:(DiagnosisRecord *)record;

@end

NS_ASSUME_NONNULL_END
