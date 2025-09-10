//
//  HealthDiagnosisView.h
//  Parrot
//
//  Created by WCF on 2025/9/10.
//

#import <UIKit/UIKit.h>
#import "ImagePickerManager.h"

@class DiagnosisRecord;
@class DiagnosisManager;
@class HealthDiagnosisView;

NS_ASSUME_NONNULL_BEGIN

@protocol HealthDiagnosisViewDelegate <NSObject>
- (void)healthDiagnosisDidComplete;
- (void)healthDiagnosisView:(HealthDiagnosisView *)view didSelectDiagnosisRecord:(DiagnosisRecord *)record;
- (void)healthDiagnosisViewDidTapMore:(HealthDiagnosisView *)view;
@end

@interface HealthDiagnosisView : UIView <ImagePickerManagerDelegate>

@property (nonatomic, weak) id<HealthDiagnosisViewDelegate> delegate;

// UI Elements
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *symptomsTextView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIView *photoPreviewContainer;
@property (nonatomic, strong) UIImageView *photoPreview;
@property (nonatomic, strong) UIButton *deletePhotoButton;
@property (nonatomic, strong) UIButton *diagnoseButton;
@property (nonatomic, strong) UIScrollView *historyScrollView;
@property (nonatomic, strong) UIStackView *historyStackView;

// Data
@property (nonatomic, strong) NSArray<DiagnosisRecord *> *diagnosisRecords;
@property (nonatomic, strong) DiagnosisManager *diagnosisManager;
@property (nonatomic, strong) UIImage *selectedPhoto;

- (void)refreshData;

@end

NS_ASSUME_NONNULL_END
