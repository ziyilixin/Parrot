//
//  HealthDiagnosisView.m
//  Parrot
//
//  Created by WCF on 2025/9/10.
//

#import "HealthDiagnosisView.h"
#import "DiagnosisManager.h"
#import "DiagnosisRecord.h"
#import "Masonry.h"
#import "ParrotColor.h"
#import "ImagePickerManager.h"

@interface HealthDiagnosisView ()
@end

@implementation HealthDiagnosisView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self loadDiagnosisHistory];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    // Main container view
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 12;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 2);
    containerView.layer.shadowOpacity = 0.1;
    containerView.layer.shadowRadius = 4;
    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 16, 0, 16));
    }];
    
    // Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Health Diagnosis";
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = ParrotMainColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [containerView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).offset(20);
        make.left.right.equalTo(containerView).inset(20);
        make.height.mas_equalTo(25);
    }];
    
    // Input section
    UIView *inputSection = [[UIView alloc] init];
    inputSection.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    inputSection.layer.cornerRadius = 8;
    [containerView addSubview:inputSection];
    [inputSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(15);
        make.left.right.equalTo(containerView).inset(20);
        make.height.mas_equalTo(160);
    }];
    
    // Symptoms input
    UILabel *symptomsLabel = [[UILabel alloc] init];
    symptomsLabel.text = @"Symptoms Description *";
    symptomsLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    symptomsLabel.textColor = ParrotTextDarkGray;
    [inputSection addSubview:symptomsLabel];
    [symptomsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(inputSection).offset(12);
        make.right.lessThanOrEqualTo(inputSection).offset(-12);
    }];
    
    UITextView *symptomsTextView = [[UITextView alloc] init];
    symptomsTextView.backgroundColor = [UIColor whiteColor];
    symptomsTextView.layer.cornerRadius = 6;
    symptomsTextView.layer.borderWidth = 1;
    symptomsTextView.layer.borderColor = ParrotBorderGray.CGColor;
    symptomsTextView.font = [UIFont systemFontOfSize:14];
    symptomsTextView.textColor = ParrotTextDarkGray;
    // 添加placeholder效果
    [self addPlaceholderToTextView:symptomsTextView placeholder:@"Describe your parrot's symptoms..."];
    [inputSection addSubview:symptomsTextView];
    self.symptomsTextView = symptomsTextView;
    [symptomsTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(symptomsLabel.mas_bottom).offset(8);
        make.left.right.equalTo(inputSection).inset(12);
        make.height.mas_equalTo(120);
    }];
    
    // Photo section
    UIView *photoSection = [[UIView alloc] init];
    photoSection.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    photoSection.layer.cornerRadius = 8;
    [containerView addSubview:photoSection];
    [photoSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inputSection.mas_bottom).offset(15);
        make.left.right.equalTo(containerView).inset(20);
        make.height.mas_equalTo(180);
    }];
    
    UILabel *photoLabel = [[UILabel alloc] init];
    photoLabel.text = @"Photo (Optional)";
    photoLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    photoLabel.textColor = ParrotTextDarkGray;
    [photoSection addSubview:photoLabel];
    [photoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(photoSection).offset(12);
        make.right.lessThanOrEqualTo(photoSection).offset(-12);
    }];
    
    // Photo button
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setTitle:@"📷 Add Photo" forState:UIControlStateNormal];
    [photoButton setTitleColor:ParrotMainColor forState:UIControlStateNormal];
    photoButton.backgroundColor = [UIColor whiteColor];
    photoButton.layer.cornerRadius = 6;
    photoButton.layer.borderWidth = 1;
    photoButton.layer.borderColor = ParrotMainColor.CGColor;
    photoButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [photoButton addTarget:self action:@selector(photoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [photoSection addSubview:photoButton];
    self.photoButton = photoButton;
    [photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(photoLabel.mas_bottom).offset(8);
        make.left.equalTo(photoSection).offset(12);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(32);
    }];
    
    // Photo preview container
    UIView *photoPreviewContainer = [[UIView alloc] init];
    photoPreviewContainer.backgroundColor = [UIColor whiteColor];
    photoPreviewContainer.layer.cornerRadius = 8;
    photoPreviewContainer.layer.borderWidth = 1;
    photoPreviewContainer.layer.borderColor = ParrotBorderGray.CGColor;
    photoPreviewContainer.hidden = YES;
    [photoSection addSubview:photoPreviewContainer];
    self.photoPreviewContainer = photoPreviewContainer;
    [photoPreviewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(photoLabel.mas_bottom).offset(8);
        make.left.equalTo(photoButton.mas_right).offset(8);
        make.right.equalTo(photoSection).offset(-12);
        make.height.mas_equalTo(140);
    }];
    
    // Delete photo button (positioned at top right corner)
    UIButton *deletePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deletePhotoButton setTitle:@"✕" forState:UIControlStateNormal];
    [deletePhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deletePhotoButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8];
    deletePhotoButton.layer.cornerRadius = 12;
    deletePhotoButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    [deletePhotoButton addTarget:self action:@selector(deletePhotoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [photoPreviewContainer addSubview:deletePhotoButton];
    self.deletePhotoButton = deletePhotoButton;
    [deletePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(photoPreviewContainer).offset(8);
        make.right.equalTo(photoPreviewContainer).offset(-8);
        make.width.height.mas_equalTo(24);
    }];
    
    // Photo preview
    UIImageView *photoPreview = [[UIImageView alloc] init];
    photoPreview.backgroundColor = [UIColor clearColor];
    photoPreview.contentMode = UIViewContentModeScaleAspectFit;
    photoPreview.clipsToBounds = YES;
    photoPreview.layer.cornerRadius = 6;
    [photoPreviewContainer addSubview:photoPreview];
    self.photoPreview = photoPreview;
    [photoPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(photoPreviewContainer).inset(8);
    }];
    
    // Diagnose button
    UIButton *diagnoseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [diagnoseButton setTitle:@"🔍 Start AI Diagnosis" forState:UIControlStateNormal];
    [diagnoseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    diagnoseButton.backgroundColor = ParrotMainColor;
    diagnoseButton.layer.cornerRadius = 8;
    diagnoseButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [diagnoseButton addTarget:self action:@selector(diagnoseButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:diagnoseButton];
    self.diagnoseButton = diagnoseButton;
    [diagnoseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(photoSection.mas_bottom).offset(20);
        make.left.right.equalTo(containerView).inset(20);
        make.height.mas_equalTo(44);
    }];
    
    // History section
    UILabel *historyLabel = [[UILabel alloc] init];
    historyLabel.text = @"Diagnosis History";
    historyLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    historyLabel.textColor = ParrotMainColor;
    [containerView addSubview:historyLabel];
    [historyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(diagnoseButton.mas_bottom).offset(25);
        make.left.right.equalTo(containerView).inset(20);
        make.height.mas_equalTo(20);
    }];
    
    // History scroll view
    UIScrollView *historyScrollView = [[UIScrollView alloc] init];
    historyScrollView.backgroundColor = [UIColor clearColor];
    historyScrollView.showsVerticalScrollIndicator = NO;
    [containerView addSubview:historyScrollView];
    self.historyScrollView = historyScrollView;
    [historyScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(historyLabel.mas_bottom).offset(10);
        make.left.right.equalTo(containerView).inset(20);
        make.height.mas_equalTo(150);
        make.bottom.equalTo(containerView).offset(-20);
    }];
    
    // History stack view
    UIStackView *historyStackView = [[UIStackView alloc] init];
    historyStackView.axis = UILayoutConstraintAxisVertical;
    historyStackView.spacing = 8;
    historyStackView.alignment = UIStackViewAlignmentFill;
    [historyScrollView addSubview:historyStackView];
    self.historyStackView = historyStackView;
    [historyStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(historyScrollView);
        make.width.equalTo(historyScrollView);
    }];
    
    // Initialize diagnosis manager
    self.diagnosisManager = [DiagnosisManager sharedManager];
}

- (void)diagnoseButtonTapped {
    // 验证输入
    if (self.symptomsTextView.text.length == 0) {
        [self showAlertWithTitle:@"" message:@"Please enter symptoms description"];
        return;
    }
    
    // 执行诊断
    NSString *photoPath = nil;
    if (self.selectedPhoto) {
        photoPath = [self saveImageToDocuments:self.selectedPhoto];
    }
    
    [self performDiagnosisWithSymptoms:self.symptomsTextView.text photoPath:photoPath];
}

- (void)photoButtonTapped {    
    UIViewController *currentVC = [self getCurrentViewController];
    ImagePickerManager *imagePickerManager = [ImagePickerManager sharedInstance];
    [imagePickerManager showImagePickerOptionsWithViewController:currentVC];
    // 关键：在 showImagePickerOptionsWithViewController 之后重新设置 delegate
    imagePickerManager.delegate = self;
}

#pragma mark - ImagePickerManagerDelegate
- (void)ImagePickerManager:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    
    if (selectedImage) {
        self.selectedPhoto = selectedImage;
        self.photoPreview.image = selectedImage;
        self.photoPreviewContainer.hidden = NO;
        self.photoButton.hidden = YES;
    }
}

- (void)ImagePickerManagerDidCancel:(UIImagePickerController *)picker {
    
}

- (void)deletePhotoButtonTapped {
    self.selectedPhoto = nil;
    self.photoPreview.image = nil;
    self.photoPreviewContainer.hidden = YES;
    self.photoButton.hidden = NO;
}

- (void)addPlaceholderToTextView:(UITextView *)textView placeholder:(NSString *)placeholder {
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.text = placeholder;
    placeholderLabel.font = textView.font;
    placeholderLabel.textColor = ParrotTextLightGray;
    placeholderLabel.numberOfLines = 0;
    [textView addSubview:placeholderLabel];
    
    [placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textView).offset(8);
        make.left.equalTo(textView).offset(5);
        make.right.lessThanOrEqualTo(textView).offset(-5);
    }];
    
    // 监听文本变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:textView];
    
    // 设置tag用于识别
    placeholderLabel.tag = 999;
    textView.tag = 1000;
}

- (void)textViewDidChange:(NSNotification *)notification {
    UITextView *textView = (UITextView *)notification.object;
    if (textView.tag == 1000) {
        UILabel *placeholderLabel = [textView viewWithTag:999];
        placeholderLabel.hidden = textView.text.length > 0;
    }
}

- (void)performDiagnosisWithSymptoms:(NSString *)symptoms photoPath:(NSString *)photoPath {
    // 显示加载指示器
    [self showLoadingIndicator];
    
    // 执行AI诊断
    [self.diagnosisManager performAIDiagnosisWithSymptoms:symptoms
                                                photoPath:photoPath
                                               completion:^(NSString *diagnosis, NSString *confidence, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingIndicator];
            
            if (error) {
                [self showAlertWithTitle:@"Error" message:@"Diagnosis failed. Please try again."];
            } else {
                // 保存诊断记录
                DiagnosisRecord *record = [[DiagnosisRecord alloc] initWithSymptoms:symptoms
                                                                         photoPath:photoPath
                                                                      aiDiagnosis:diagnosis
                                                                       confidence:confidence];
                record.userId = [LFWebData shared].userId;
                
                if ([self.diagnosisManager saveDiagnosisRecord:record]) {
                    [self showDiagnosisResult:diagnosis confidence:confidence];
                    [self loadDiagnosisHistory];
                    
                    if ([self.delegate respondsToSelector:@selector(healthDiagnosisDidComplete)]) {
                        [self.delegate healthDiagnosisDidComplete];
                    }
                } else {
                    [self showAlertWithTitle:@"Error" message:@"Failed to save diagnosis record"];
                }
            }
        });
    }];
}

- (void)showDiagnosisResult:(NSString *)diagnosis confidence:(NSString *)confidence {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AI Diagnosis Result"
                                                                   message:[NSString stringWithFormat:@"Confidence: %@\n\n%@", confidence, diagnosis]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    
    UIViewController *currentVC = [self getCurrentViewController];
    [currentVC presentViewController:alert animated:YES completion:nil];
}

- (void)loadDiagnosisHistory {
    NSString *userId = [LFWebData shared].userId;
    if (userId && userId.length > 0) {
        self.diagnosisRecords = [self.diagnosisManager getDiagnosisRecordsForUserId:userId];
    } else {
        self.diagnosisRecords = @[];
    }
    
    [self updateHistoryDisplay];
}

- (void)updateHistoryDisplay {
    // 清除现有的历史记录视图
    for (UIView *subview in self.historyStackView.arrangedSubviews) {
        [self.historyStackView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    
    if (self.diagnosisRecords.count == 0) {
        UILabel *emptyLabel = [[UILabel alloc] init];
        emptyLabel.text = @"No diagnosis records yet";
        emptyLabel.textColor = ParrotTextGray;
        emptyLabel.font = [UIFont systemFontOfSize:14];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self.historyStackView addArrangedSubview:emptyLabel];
    } else {
        // 显示最近的5条记录
        NSInteger maxRecords = MIN(5, self.diagnosisRecords.count);
        for (NSInteger i = 0; i < maxRecords; i++) {
            DiagnosisRecord *record = self.diagnosisRecords[i];
            UIView *recordView = [self createHistoryRecordView:record];
            [self.historyStackView addArrangedSubview:recordView];
        }
    }
}

- (UIView *)createHistoryRecordView:(DiagnosisRecord *)record {
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 8;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 1);
    containerView.layer.shadowOpacity = 0.1;
    containerView.layer.shadowRadius = 2;
    
    // Date label
    UILabel *dateLabel = [[UILabel alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd, yyyy";
    dateLabel.text = [formatter stringFromDate:record.createdDate];
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.textColor = ParrotTextGray;
    [containerView addSubview:dateLabel];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(containerView).offset(12);
        make.right.lessThanOrEqualTo(containerView).offset(-12);
    }];
    
    // Symptoms label
    UILabel *symptomsLabel = [[UILabel alloc] init];
    symptomsLabel.text = record.symptoms;
    symptomsLabel.font = [UIFont systemFontOfSize:14];
    symptomsLabel.textColor = ParrotMainColor;
    symptomsLabel.numberOfLines = 2;
    [containerView addSubview:symptomsLabel];
    [symptomsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dateLabel.mas_bottom).offset(4);
        make.left.equalTo(containerView).offset(12);
        make.right.equalTo(containerView).offset(-12);
    }];
    
    // Confidence label
    UILabel *confidenceLabel = [[UILabel alloc] init];
    confidenceLabel.text = [NSString stringWithFormat:@"Confidence: %@", record.confidence];
    confidenceLabel.font = [UIFont systemFontOfSize:12];
    confidenceLabel.textColor = ParrotTextGray;
    [containerView addSubview:confidenceLabel];
    [confidenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(symptomsLabel.mas_bottom).offset(4);
        make.left.equalTo(containerView).offset(12);
        make.bottom.equalTo(containerView).offset(-12);
        make.right.lessThanOrEqualTo(containerView).offset(-12);
    }];
    
    return containerView;
}

- (void)showLoadingIndicator {
    // 简单的加载指示器
    self.diagnoseButton.enabled = NO;
    [self.diagnoseButton setTitle:@"Diagnosing..." forState:UIControlStateNormal];
}

- (void)hideLoadingIndicator {
    self.diagnoseButton.enabled = YES;
    [self.diagnoseButton setTitle:@"Start AI Diagnosis" forState:UIControlStateNormal];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    
    UIViewController *currentVC = [self getCurrentViewController];
    [currentVC presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)getCurrentViewController {
    UIResponder *responder = self;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}

- (void)refreshData {
    [self loadDiagnosisHistory];
}

- (NSString *)saveImageToDocuments:(UIImage *)image {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"diagnosis_%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [imageData writeToFile:filePath atomically:YES];
    
    return fileName; // 只返回文件名，不返回完整路径
}


@end
