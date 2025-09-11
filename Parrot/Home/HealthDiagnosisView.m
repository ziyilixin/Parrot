//
//  HealthDiagnosisView.m
//  Parrot
//
//  Created by WCF on 2025/9/10.
//

#import "HealthDiagnosisView.h"
#import "DiagnosisManager.h"
#import "DiagnosisRecord.h"
#import "FreeUsageManager.h"
#import "Masonry.h"
#import "ParrotColor.h"
#import "ImagePickerManager.h"
#import "VoiceRecordManager.h"

@interface HealthDiagnosisView ()<VoiceRecordManagerDelegate>
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *fileName;
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
        make.height.mas_equalTo(220); // 增加高度以容纳语音按钮
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
    
    // Voice button
    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [voiceButton setTitle:@"🎤 Voice Input" forState:UIControlStateNormal];
    [voiceButton setTitleColor:ParrotMainColor forState:UIControlStateNormal];
    voiceButton.backgroundColor = [UIColor whiteColor];
    voiceButton.layer.cornerRadius = 6;
    voiceButton.layer.borderWidth = 1;
    voiceButton.layer.borderColor = ParrotMainColor.CGColor;
    voiceButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [voiceButton addTarget:self action:@selector(voiceButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [inputSection addSubview:voiceButton];
    self.voiceButton = voiceButton;
    [voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(symptomsTextView.mas_bottom).offset(8);
        make.left.right.equalTo(inputSection).inset(12);
        make.height.mas_equalTo(36);
        make.bottom.equalTo(inputSection).offset(-12);
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
    historyScrollView.showsVerticalScrollIndicator = YES; // 显示滚动指示器
    historyScrollView.showsHorizontalScrollIndicator = NO;
    [containerView addSubview:historyScrollView];
    self.historyScrollView = historyScrollView;
    [historyScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(historyLabel.mas_bottom).offset(10);
        make.left.right.equalTo(containerView).inset(20);
        make.height.mas_equalTo(350); // 减少高度，让More按钮更容易看到
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
        [self showAlertWithTitle:@"Input Required" message:@"Please enter symptoms description"];
        return;
    }
    
    NSString *userId = [LFWebData shared].userId;
    if (!userId || userId.length == 0) {
        [self showAlertWithTitle:@"Login Required" message:@"Please login to use AI diagnosis"];
        return;
    }
    
    // 检查免费次数
    NSInteger remainingFreeUsage = [[FreeUsageManager sharedManager] getRemainingFreeUsageForUser:userId];
    
    if (remainingFreeUsage > 0) {
        // 有免费次数，直接使用免费机会
        [self performDiagnosisWithFreeUsage:userId];
    } else {
        // 没有免费次数，检查金币
        [self checkCoinsAndPerformDiagnosis:userId];
    }
}

- (void)performDiagnosisWithFreeUsage:(NSString *)userId {
    // 使用免费机会
    BOOL success = [[FreeUsageManager sharedManager] useFreeUsageForUser:userId];
    if (success) {
        // 执行诊断，标记为使用免费机会
        [self performDiagnosisWithSymptoms:self.symptomsTextView.text photoPath:self.filePath useFreeUsage:YES];
    } else {
        [self showAlertWithTitle:@"Error" message:@"Failed to use free diagnosis. Please try again."];
    }
}

- (void)checkCoinsAndPerformDiagnosis:(NSString *)userId {
    // 获取当前可用金币
    [UserRepository getUserCoinsWithCompletion:^(NSInteger availableCoins, BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                if (availableCoins >= 5) {
                    // 金币足够，执行诊断
                    [self performDiagnosisWithCoins:userId];
                } else {
                    // 金币不足，提示充值
                    [self showInsufficientCoinsAlert];
                }
            } else {
                [self showAlertWithTitle:@"Error" message:@"Failed to check coins. Please try again."];
            }
        });
    } completionHandler:^{
        
    }];
}

- (void)performDiagnosisWithCoins:(NSString *)userId {
    // 执行诊断，标记为使用金币
    [self performDiagnosisWithSymptoms:self.symptomsTextView.text photoPath:self.filePath useFreeUsage:NO];
}

- (void)showInsufficientCoinsAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Insufficient Coins"
                                                                   message:@"You need at least 5 coins to use AI diagnosis. Please go to Mine page to purchase coins."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    
    UIViewController *currentVC = [self getCurrentViewController];
    [currentVC presentViewController:alert animated:YES completion:nil];
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
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fileName = [NSString stringWithFormat:@"diagnosis_%@.jpg", [[NSUUID UUID] UUIDString]];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.8);
        [imageData writeToFile:filePath atomically:YES];
        self.fileName = fileName;
        self.filePath = filePath;
    }
}

- (void)ImagePickerManagerDidCancel:(UIImagePickerController *)picker {
    
}

- (void)deletePhotoButtonTapped {
    self.selectedPhoto = nil;
    self.photoPreview.image = nil;
    self.photoPreviewContainer.hidden = YES;
    self.photoButton.hidden = NO;
    self.fileName = nil;
    self.filePath = nil;
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

- (void)performDiagnosisWithSymptoms:(NSString *)symptoms photoPath:(NSString *)photoPath useFreeUsage:(BOOL)useFreeUsage {
    // 显示加载指示器
    [self showLoadingIndicator];
    
    // 执行AI诊断
    [self.diagnosisManager performAIDiagnosisWithSymptoms:symptoms
                                                photoPath:photoPath
                                               completion:^(NSString *diagnosis, NSString *confidence, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingIndicator];
            
            if (error) {
                // 显示具体的错误信息
                NSString *errorMessage = error.localizedDescription;
                [self showAlertWithTitle:@"Diagnosis Failed" message:errorMessage];
            } else {
                // 诊断成功，根据使用类型保存记录
                [self handleSuccessfulDiagnosis:symptoms diagnosis:diagnosis confidence:confidence useFreeUsage:useFreeUsage];
            }
        });
    }];
}

- (void)handleSuccessfulDiagnosis:(NSString *)symptoms diagnosis:(NSString *)diagnosis confidence:(NSString *)confidence useFreeUsage:(BOOL)useFreeUsage {
    if (useFreeUsage) {
        // 使用免费机会，直接保存记录
        [self saveDiagnosisRecord:symptoms diagnosis:diagnosis confidence:confidence];
    } else {
        // 使用金币，需要扣减金币
        [self deductCoinsAndSaveRecord:symptoms diagnosis:diagnosis confidence:confidence];
    }
}

- (void)saveDiagnosisRecord:(NSString *)symptoms diagnosis:(NSString *)diagnosis confidence:(NSString *)confidence {
    DiagnosisRecord *record = [[DiagnosisRecord alloc] initWithSymptoms:symptoms
                                                             photoPath:self.fileName
                                                          aiDiagnosis:diagnosis
                                                           confidence:confidence];
    
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

- (void)deductCoinsAndSaveRecord:(NSString *)symptoms diagnosis:(NSString *)diagnosis confidence:(NSString *)confidence {
    // 扣减金币
    [CoinReository reviewModeConsumeWithOutlay:5 source:@"aichat" completion:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                // 金币扣减成功，保存记录
                [self saveDiagnosisRecord:symptoms diagnosis:diagnosis confidence:confidence];
            } else {
                [self showAlertWithTitle:@"Error" message:@"Failed to deduct coins. Please try again."];
            }
        });
    } completionHandler:^{
        
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
        // 显示最近的3条记录
        NSInteger maxRecords = MIN(3, self.diagnosisRecords.count);
        for (NSInteger i = 0; i < maxRecords; i++) {
            DiagnosisRecord *record = self.diagnosisRecords[i];
            UIView *recordView = [self createHistoryRecordView:record];
            [self.historyStackView addArrangedSubview:recordView];
        }
        
        // 如果记录超过3条，显示More按钮和提示
        if (self.diagnosisRecords.count > 3) {
            // 添加提示标签
            UILabel *hintLabel = [[UILabel alloc] init];
            hintLabel.text = @"💡 Swipe to see more records";
            hintLabel.textColor = ParrotTextGray;
            hintLabel.font = [UIFont systemFontOfSize:12];
            hintLabel.textAlignment = NSTextAlignmentCenter;
            [self.historyStackView addArrangedSubview:hintLabel];
            
            UIButton *moreButton = [self createMoreButton];
            [self.historyStackView addArrangedSubview:moreButton];
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
    
    // 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordViewTapped:)];
    [containerView addGestureRecognizer:tapGesture];
    containerView.userInteractionEnabled = YES;
    containerView.tag = [self.diagnosisRecords indexOfObject:record]; // 存储记录索引
    
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
        make.right.lessThanOrEqualTo(containerView).offset(-40); // 为箭头留出空间
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
        make.right.equalTo(containerView).offset(-40); // 为箭头留出空间
    }];
    
    // Diagnosis result label (显示真实的诊断内容)
    UILabel *diagnosisLabel = [[UILabel alloc] init];
    diagnosisLabel.text = record.aiDiagnosis;
    diagnosisLabel.font = [UIFont systemFontOfSize:12];
    diagnosisLabel.textColor = ParrotTextGray;
    diagnosisLabel.numberOfLines = 1;
    [containerView addSubview:diagnosisLabel];
    [diagnosisLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(symptomsLabel.mas_bottom).offset(4);
        make.left.equalTo(containerView).offset(12);
        make.bottom.equalTo(containerView).offset(-12);
        make.right.lessThanOrEqualTo(containerView).offset(-40); // 为箭头留出空间
    }];
    
    // 箭头指示器
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.image = [UIImage systemImageNamed:@"chevron.right"];
    arrowImageView.tintColor = ParrotTextGray;
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    [containerView addSubview:arrowImageView];
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView);
        make.right.equalTo(containerView).offset(-12);
        make.width.height.mas_equalTo(16);
    }];
    
    return containerView;
}

- (UIButton *)createMoreButton {
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.backgroundColor = ParrotMainColor;
    moreButton.layer.cornerRadius = 8;
    moreButton.layer.shadowColor = [UIColor blackColor].CGColor;
    moreButton.layer.shadowOffset = CGSizeMake(0, 2);
    moreButton.layer.shadowOpacity = 0.15;
    moreButton.layer.shadowRadius = 4;
    
    [moreButton setTitle:@"📋 View All Records" forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    moreButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    
    [moreButton addTarget:self action:@selector(moreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    return moreButton;
}

- (void)moreButtonTapped {
    if ([self.delegate respondsToSelector:@selector(healthDiagnosisViewDidTapMore:)]) {
        [self.delegate healthDiagnosisViewDidTapMore:self];
    }
}

- (void)recordViewTapped:(UITapGestureRecognizer *)gesture {
    UIView *tappedView = gesture.view;
    NSInteger recordIndex = tappedView.tag;
    
    if (recordIndex >= 0 && recordIndex < self.diagnosisRecords.count) {
        DiagnosisRecord *selectedRecord = self.diagnosisRecords[recordIndex];
        
        if ([self.delegate respondsToSelector:@selector(healthDiagnosisView:didSelectDiagnosisRecord:)]) {
            [self.delegate healthDiagnosisView:self didSelectDiagnosisRecord:selectedRecord];
        }
    }
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

- (void)voiceButtonTapped {
    // 语音输入功能
    [self endEditing:YES];
    
    // 先检查麦克风权限
    [[VoiceRecordManager sharedInstance] checkMicrophonePermission:^(BOOL micGranted) {
        if (micGranted) {
            [UserDefaults setBool:NO forKey:@"MicrophonePermissionDenied"];
            [UserDefaults synchronize];
            
            // 再检查语音识别权限
            [[VoiceRecordManager sharedInstance] checkSpeechRecognitionPermission:^(BOOL granted) {
                if (granted) {
                    [UserDefaults setBool:NO forKey:@"SpeechRecognitionPermissionDenied"];
                    [UserDefaults synchronize];
                    
                    [VoiceRecordManager sharedInstance].delegate = self;
                    [[VoiceRecordManager sharedInstance] startRecordingWithView:self];
                } else {
                    UIViewController *currentVC = [self getCurrentViewController];
                    BOOL hasPermissionDenied = [UserDefaults boolForKey:@"SpeechRecognitionPermissionDenied"];
                    if (hasPermissionDenied) {
                        [[VoiceRecordManager sharedInstance] showPermissionAlertWithMessage:@"Please allow voice recognition permissions in Settings" viewController:currentVC];
                    }
                    [UserDefaults setBool:YES forKey:@"SpeechRecognitionPermissionDenied"];
                    [UserDefaults synchronize];
                }
            }];
        } else {
            BOOL hasPermissionDenied = [UserDefaults boolForKey:@"MicrophonePermissionDenied"];
            if (hasPermissionDenied) {
                UIViewController *currentVC = [self getCurrentViewController];
                [[VoiceRecordManager sharedInstance] showPermissionAlertWithMessage:@"Please allow microphone access in Settings" viewController:currentVC];
            }
            [UserDefaults setBool:YES forKey:@"MicrophonePermissionDenied"];
            [UserDefaults synchronize];
        }
    }];
}

#pragma mark - VoiceRecordManagerDelegate
- (void)VoiceRecordManagerDidFinishRecordingWithText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (text.length > 0) {
            self.symptomsTextView.text = text;
            // 手动隐藏占位文字
            UILabel *placeholderLabel = [self.symptomsTextView viewWithTag:999];
            if (placeholderLabel) {
                placeholderLabel.hidden = YES;
            }
        }
    });
}

- (void)VoiceRecordManagerDidFailRecording {
    NSLog(@"语音识别失败");
    // 可以在这里显示一个友好的提示，但不显示技术性错误信息
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"Voice Recognition Failed" 
                         message:@"Unable to recognize speech. Please try again or type your symptoms manually."];
    });
}

- (void)VoiceRecordManagerDidUpdateDuration:(NSInteger)duration {
    // 可以在这里处理录音时长的更新
}

@end
