//
//  AddParrotViewController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "AddParrotViewController.h"
#import "ParrotDataManager.h"
#import <PhotosUI/PhotosUI.h>
#import <objc/runtime.h>

@interface AddParrotViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate>

// UI Components
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

// Photo Section
@property (nonatomic, strong) UIView *photoContainerView;
@property (nonatomic, strong) UIImageView *parrotImageView;
@property (nonatomic, strong) UIButton *photoButton;

// Form Fields
@property (nonatomic, strong) UIView *formContainer;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *breedTextField;
@property (nonatomic, strong) UITextField *colorTextField;
@property (nonatomic, strong) UIButton *birthdateButton;
@property (nonatomic, strong) UIDatePicker *datePicker;

// Action Buttons
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *cancelButton;


// Data
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSDate *selectedBirthdate;

@end

@implementation AddParrotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupNavigationBar];
    [self setupDefaultValues];
}

- (void)setupNavigationBar {
    self.title = @"Add Parrot";
    self.navigationController.navigationBar.hidden = NO;
    
    // Navigation bar style
    [self.navigationController.navigationBar setBackgroundColor:ColorFFFFFF];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
        NSForegroundColorAttributeName: ParrotTextDarkGray,
        NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightBold]
    }];
}

- (void)setupDefaultValues {
    // Set default birthdate to 1 year ago
    self.selectedBirthdate = [NSDate dateWithTimeIntervalSinceNow:-(365 * 24 * 60 * 60)];
    [self updateBirthdateButtonTitle];
}

- (void)setupUI {
    // 简化背景设置
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.95 blue:0.9 alpha:1.0];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(16, kStatusBarHeight + 20, 34, 34);
    // Use system back icon with consistent color
    UIImage *backIcon = [UIImage systemImageNamed:@"chevron.left"];
    backIcon = [backIcon imageWithTintColor:ParrotTextDarkGray renderingMode:UIImageRenderingModeAlwaysOriginal];
    [backBtn setImage:backIcon forState:UIControlStateNormal];
    [backBtn setImage:backIcon forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Information";
    titleLabel.textColor = ParrotTextDarkGray;
    titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(backBtn);
    }];
    
    // Scroll view - 使用更简单的约束
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 使用edges约束，让scrollView填满整个view
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(backBtn.mas_bottom).offset(20);
    }];
    
    // Content view
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:contentView];
    self.contentView = contentView;
    
    // 使用edges约束，但设置width等于scrollView
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    
    // 添加照片选择功能
    [self setupPhotoSection];
    
    // 添加表单字段
    [self setupFormFields];
    
    // 添加操作按钮
    [self setupActionButtons];
}


- (void)setupPhotoSection {
    // Photo container
    UIView *photoContainer = [[UIView alloc] init];
    photoContainer.backgroundColor = ColorFFFFFF;
    photoContainer.layer.cornerRadius = 16;
    photoContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    photoContainer.layer.shadowOffset = CGSizeMake(0, 2);
    photoContainer.layer.shadowOpacity = 0.1;
    photoContainer.layer.shadowRadius = 8;
    [self.contentView addSubview:photoContainer];
    self.photoContainerView = photoContainer;
    
    [photoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(160);
    }];
    
    // Photo title
    UILabel *photoTitle = [[UILabel alloc] init];
    photoTitle.text = @"Parrot Photo";
    photoTitle.textColor = ParrotTextDarkGray;
    photoTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    [photoContainer addSubview:photoTitle];
    
    [photoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(photoContainer).offset(16);
        make.left.equalTo(photoContainer).offset(20);
    }];
    
    // Photo image view
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = ParrotBgGradientTop;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = 50;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 3;
    imageView.layer.borderColor = ParrotBgGradientTop.CGColor;
    [photoContainer addSubview:imageView];
    self.parrotImageView = imageView;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(photoContainer).offset(10);
        make.left.equalTo(photoContainer).offset(20);
        make.width.height.mas_equalTo(100);
    }];
    
    // Photo button
    UIButton *photoButton = [[UIButton alloc] init];
    [photoButton setTitle:@"Choose Photo" forState:UIControlStateNormal];
    [photoButton setTitleColor:ColorFFFFFF forState:UIControlStateNormal];
    photoButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    photoButton.backgroundColor = ParrotMainColor;
    photoButton.layer.cornerRadius = 8;
    [photoButton addTarget:self action:@selector(photoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [photoContainer addSubview:photoButton];
    self.photoButton = photoButton;
    
    [photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imageView);
        make.left.equalTo(imageView.mas_right).offset(20);
        make.right.equalTo(photoContainer).offset(-20);
        make.height.mas_equalTo(44);
    }];
    
    // Default placeholder image
    imageView.image = ImageNamed(@"login_logo");
}

- (void)setupFormFields {
    // Create form container
    UIView *formContainer = [[UIView alloc] init];
    formContainer.backgroundColor = ColorFFFFFF;
    formContainer.layer.cornerRadius = 16;
    formContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    formContainer.layer.shadowOffset = CGSizeMake(0, 2);
    formContainer.layer.shadowOpacity = 0.1;
    formContainer.layer.shadowRadius = 8;
    [self.contentView addSubview:formContainer];
    self.formContainer = formContainer;
    
    [formContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photoContainerView.mas_bottom).offset(20);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
    }];
    
    // Form title
    UILabel *formTitle = [[UILabel alloc] init];
    formTitle.text = @"Parrot Information";
    formTitle.textColor = ParrotTextDarkGray;
    formTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    [formContainer addSubview:formTitle];
    
    [formTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(formContainer).offset(20);
        make.left.equalTo(formContainer).offset(20);
    }];
    
    // Name field
    UIView *nameFieldView = [self createFieldViewWithTitle:@"Name *" placeholder:@"Enter parrot name"];
    self.nameTextField = (UITextField *)[nameFieldView viewWithTag:100];
    [formContainer addSubview:nameFieldView];
    
    [nameFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(formTitle.mas_bottom).offset(20);
        make.left.right.equalTo(formContainer);
        make.height.mas_equalTo(70);
    }];
    
    // Breed field
    UIView *breedFieldView = [self createFieldViewWithTitle:@"Breed" placeholder:@"e.g., Budgerigar, Cockatiel"];
    self.breedTextField = (UITextField *)[breedFieldView viewWithTag:100];
    [formContainer addSubview:breedFieldView];
    
    [breedFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameFieldView.mas_bottom);
        make.left.right.equalTo(formContainer);
        make.height.mas_equalTo(70);
    }];
    
    // Color field
    UIView *colorFieldView = [self createFieldViewWithTitle:@"Color" placeholder:@"e.g., Green, Blue, Yellow"];
    self.colorTextField = (UITextField *)[colorFieldView viewWithTag:100];
    [formContainer addSubview:colorFieldView];
    
    [colorFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(breedFieldView.mas_bottom);
        make.left.right.equalTo(formContainer);
        make.height.mas_equalTo(70);
    }];
    
    // Birthdate field
    UIView *birthdateFieldView = [self createBirthdateFieldView];
    [formContainer addSubview:birthdateFieldView];
    
    [birthdateFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(colorFieldView.mas_bottom);
        make.left.right.equalTo(formContainer);
        make.height.mas_equalTo(70);
        make.bottom.equalTo(formContainer).offset(-20);
    }];
}

- (UIView *)createFieldViewWithTitle:(NSString *)title placeholder:(NSString *)placeholder {
    UIView *fieldView = [[UIView alloc] init];
    
    // Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = ParrotTextDarkGray;
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [fieldView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fieldView).offset(8);
        make.left.equalTo(fieldView).offset(20);
    }];
    
    // Text field
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.textColor = ParrotTextDarkGray;
    textField.font = [UIFont systemFontOfSize:16];
    textField.backgroundColor = ParrotBgGradientBottom;
    textField.layer.cornerRadius = 8;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = ParrotBorderGray.CGColor;
    textField.delegate = self;
    textField.tag = 100; // Tag to identify text field
    
    // Add padding to text field
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    [fieldView addSubview:textField];
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.left.equalTo(fieldView).offset(20);
        make.right.equalTo(fieldView).offset(-20);
        make.height.mas_equalTo(44);
    }];
    
    return fieldView;
}

- (UIView *)createBirthdateFieldView {
    UIView *fieldView = [[UIView alloc] init];
    
    // Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Birth Date";
    titleLabel.textColor = ParrotTextDarkGray;
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [fieldView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fieldView).offset(8);
        make.left.equalTo(fieldView).offset(20);
    }];
    
    // Date button
    UIButton *dateButton = [[UIButton alloc] init];
    [dateButton setTitleColor:ParrotTextDarkGray forState:UIControlStateNormal];
    dateButton.titleLabel.font = [UIFont systemFontOfSize:16];
    dateButton.backgroundColor = ParrotBgGradientBottom;
    dateButton.layer.cornerRadius = 8;
    dateButton.layer.borderWidth = 1;
    dateButton.layer.borderColor = ParrotBorderGray.CGColor;
    dateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    dateButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    [dateButton addTarget:self action:@selector(birthdateButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [fieldView addSubview:dateButton];
    self.birthdateButton = dateButton;
    
    [dateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.left.equalTo(fieldView).offset(20);
        make.right.equalTo(fieldView).offset(-20);
        make.height.mas_equalTo(44);
    }];
    
    return fieldView;
}

- (void)setupActionButtons {
    // Save button
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"Save Parrot" forState:UIControlStateNormal];
    [saveButton setTitleColor:ColorFFFFFF forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    saveButton.backgroundColor = ParrotMainColor;
    saveButton.layer.cornerRadius = 12;
    [saveButton addTarget:self action:@selector(saveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:saveButton];
    self.saveButton = saveButton;
    
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.formContainer.mas_bottom).offset(30);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    // Cancel button
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:ParrotTextLightGray forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.borderColor = ParrotBorderGray.CGColor;
    cancelButton.layer.cornerRadius = 12;
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(saveButton.mas_bottom).offset(12);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    // 关键：设置contentView的bottom约束，基于最后一个子视图
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(cancelButton.mas_bottom).offset(30);
    }];
}

#pragma mark - Actions

- (void)photoButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Photo" 
                                                                  message:@"Select photo source"
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Camera option
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" 
                                                               style:UIAlertActionStyleDefault 
                                                             handler:^(UIAlertAction *action) {
            [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }];
        [alert addAction:cameraAction];
    }
    
    // Photo Library option
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Photo Library" 
                                                            style:UIAlertActionStyleDefault 
                                                          handler:^(UIAlertAction *action) {
        [self presentPHPickerViewController];
    }];
    [alert addAction:libraryAction];
    
    // Cancel option
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" 
                                                           style:UIAlertActionStyleCancel 
                                                         handler:nil];
    [alert addAction:cancelAction];
    
    // For iPad
    alert.popoverPresentationController.sourceView = self.photoButton;
    alert.popoverPresentationController.sourceRect = self.photoButton.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)presentPHPickerViewController {
    if (@available(iOS 14.0, *)) {
        PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
        config.selectionLimit = 1;
        config.filter = [PHPickerFilter imagesFilter];
        
        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)birthdateButtonTapped {
    // 创建日期选择器视图控制器
    UIViewController *datePickerVC = [[UIViewController alloc] init];
    datePickerVC.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    // 创建容器视图
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 16;
    containerView.layer.masksToBounds = YES;
    [datePickerVC.view addSubview:containerView];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(datePickerVC.view);
        make.left.equalTo(datePickerVC.view).offset(20);
        make.right.equalTo(datePickerVC.view).offset(-20);
        make.height.mas_equalTo(400);
    }];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Select Birth Date";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).offset(20);
        make.left.right.equalTo(containerView);
        make.height.mas_equalTo(30);
    }];
    
    // 日期选择器
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    datePicker.maximumDate = [NSDate date];
    datePicker.date = self.selectedBirthdate;
    datePicker.transform = CGAffineTransformMakeScale(1.2, 1.2); // 放大日期选择器
    [containerView addSubview:datePicker];
    
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.left.right.equalTo(containerView);
        make.height.mas_equalTo(200);
    }];
    
    // 按钮容器
    UIView *buttonContainer = [[UIView alloc] init];
    [containerView addSubview:buttonContainer];
    
    [buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(datePicker.mas_bottom).offset(20);
        make.left.right.equalTo(containerView);
        make.bottom.equalTo(containerView).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    // 取消按钮
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
    cancelButton.layer.cornerRadius = 8;
    [cancelButton addTarget:self action:@selector(dismissDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:cancelButton];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(buttonContainer).offset(20);
        make.centerY.equalTo(buttonContainer);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    
    // 确定按钮
    UIButton *selectButton = [[UIButton alloc] init];
    [selectButton setTitle:@"Select" forState:UIControlStateNormal];
    [selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    selectButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    selectButton.backgroundColor = [UIColor systemBlueColor];
    selectButton.layer.cornerRadius = 8;
    [selectButton addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:selectButton];
    
    [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(buttonContainer).offset(-20);
        make.centerY.equalTo(buttonContainer);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    
    // 保存日期选择器的引用
    objc_setAssociatedObject(selectButton, @"datePicker", datePicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(selectButton, @"datePickerVC", datePickerVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(cancelButton, @"datePickerVC", datePickerVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 添加点击背景关闭手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    tapGesture.cancelsTouchesInView = NO;
    [datePickerVC.view addGestureRecognizer:tapGesture];
    objc_setAssociatedObject(tapGesture, @"datePickerVC", datePickerVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 模态展示
    datePickerVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    datePickerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:datePickerVC animated:YES completion:nil];
}

- (void)selectDate:(UIButton *)sender {
    UIDatePicker *datePicker = objc_getAssociatedObject(sender, @"datePicker");
    UIViewController *datePickerVC = objc_getAssociatedObject(sender, @"datePickerVC");
    
    if (datePicker) {
        self.selectedBirthdate = datePicker.date;
        [self updateBirthdateButtonTitle];
    }
    
    [datePickerVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissDatePicker:(id)sender {
    UIViewController *datePickerVC = nil;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        datePickerVC = objc_getAssociatedObject(sender, @"datePickerVC");
    } else if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        datePickerVC = objc_getAssociatedObject(sender, @"datePickerVC");
    }
    
    if (datePickerVC) {
        [datePickerVC dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)updateBirthdateButtonTitle {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    NSString *dateString = [formatter stringFromDate:self.selectedBirthdate];
    [self.birthdateButton setTitle:dateString forState:UIControlStateNormal];
}

- (void)saveButtonTapped {
    // Validate required fields
    if (!self.nameTextField.text || self.nameTextField.text.length == 0) {
        [self showAlertWithTitle:@"Error" message:@"Please enter parrot name."];
        return;
    }
    
    // Create ParrotInfo object
    ParrotInfo *parrotInfo = [[ParrotInfo alloc] init];
    parrotInfo.name = self.nameTextField.text;
    parrotInfo.breed = self.breedTextField.text ?: @"";
    parrotInfo.color = self.colorTextField.text ?: @"";
    parrotInfo.birthDate = self.selectedBirthdate;
    parrotInfo.userId = [LFWebData shared].userId ?: @"";
    
    // Save photo if selected
    if (self.selectedImage) {
        NSString *photoPath = [self saveImageToDocuments:self.selectedImage];
        parrotInfo.photoPath = photoPath;
    }
    
    // Save to database
    ParrotDataManager *manager = [ParrotDataManager sharedManager];
    BOOL success = [manager saveParrotInfo:parrotInfo];
    
    if (success) {
        // Notify delegate
        if ([self.delegate respondsToSelector:@selector(didAddParrotSuccessfully)]) {
            [self.delegate didAddParrotSuccessfully];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showAlertWithTitle:@"Error" message:@"Failed to save parrot information. Please try again."];
    }
}

- (void)cancelButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Methods

- (NSString *)saveImageToDocuments:(UIImage *)image {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"parrot_%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [imageData writeToFile:filePath atomically:YES];
    
    return fileName; // Return just the filename, not the full path
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    
    if (selectedImage) {
        self.selectedImage = selectedImage;
        self.parrotImageView.image = selectedImage;
        [self.photoButton setTitle:@"Change Photo" forState:UIControlStateNormal];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14.0)) {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (results.count > 0) {
        PHPickerResult *result = results.firstObject;
        [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
            if ([object isKindOfClass:[UIImage class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *selectedImage = (UIImage *)object;
                    self.selectedImage = selectedImage;
                    self.parrotImageView.image = selectedImage;
                    [self.photoButton setTitle:@"Change Photo" forState:UIControlStateNormal];
                });
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)backClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
