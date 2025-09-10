//
//  ParrotProfileView.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "ParrotProfileView.h"
#import "ParrotDataManager.h"

@interface ParrotProfileView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *parrotImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *breedLabel;
@property (nonatomic, strong) UILabel *colorLabel;
@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) UILabel *emptyStateLabel;
@property (nonatomic, strong) UIButton *addParrotButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) ParrotInfo *currentParrotInfo;
@end

@implementation ParrotProfileView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self loadParrotData];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    // Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"My Parrot";
    titleLabel.textColor = ParrotTextDarkGray;
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(16);
        make.left.equalTo(self).offset(20);
    }];
    
    // Container view
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = ColorFFFFFF;
    containerView.layer.cornerRadius = 16;
    containerView.layer.masksToBounds = YES;
    // Add shadow effect
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 2);
    containerView.layer.shadowOpacity = 0.1;
    containerView.layer.shadowRadius = 8;
    containerView.layer.masksToBounds = NO;
    [self addSubview:containerView];
    self.containerView = containerView;
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(12);
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.bottom.equalTo(self).offset(-16);
        make.height.mas_equalTo(120);
    }];
    
    [self setupParrotInfoView];
    [self setupEmptyStateView];
}

- (void)setupParrotInfoView {
    // Parrot photo
    UIImageView *parrotImageView = [[UIImageView alloc] init];
    parrotImageView.image = ImageNamed(@"login_logo"); // Default parrot image
    parrotImageView.contentMode = UIViewContentModeScaleAspectFill;
    parrotImageView.layer.cornerRadius = 35;
    parrotImageView.layer.masksToBounds = YES;
    parrotImageView.backgroundColor = ParrotBgGradientTop;
    [self.containerView addSubview:parrotImageView];
    self.parrotImageView = parrotImageView;
    [parrotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(20);
        make.centerY.equalTo(self.containerView);
        make.width.height.mas_equalTo(70);
    }];
    
    // Parrot name
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"Coco";
    nameLabel.textColor = ParrotTextDarkGray;
    nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [self.containerView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(parrotImageView.mas_right).offset(16);
        make.top.equalTo(parrotImageView).offset(5);
    }];
    
    // Breed label
    UILabel *breedLabel = [[UILabel alloc] init];
    breedLabel.text = @"Budgerigar";
    breedLabel.textColor = ParrotTextMediumGray;
    breedLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [self.containerView addSubview:breedLabel];
    self.breedLabel = breedLabel;
    [breedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel);
        make.top.equalTo(nameLabel.mas_bottom).offset(4);
    }];
    
    // Color label
    UILabel *colorLabel = [[UILabel alloc] init];
    colorLabel.text = @"Green";
    colorLabel.textColor = ParrotPrimaryGreen;
    colorLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    colorLabel.backgroundColor = [ParrotPrimaryGreen colorWithAlphaComponent:0.1];
    colorLabel.layer.cornerRadius = 8;
    colorLabel.layer.masksToBounds = YES;
    colorLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:colorLabel];
    self.colorLabel = colorLabel;
    [colorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel);
        make.top.equalTo(breedLabel.mas_bottom).offset(6);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(20);
    }];
    
    // Age label
    UILabel *ageLabel = [[UILabel alloc] init];
    ageLabel.text = @"2 years";
    ageLabel.textColor = ParrotTextMediumGray;
    ageLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    [self.containerView addSubview:ageLabel];
    self.ageLabel = ageLabel;
    [ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(colorLabel.mas_right).offset(12);
        make.centerY.equalTo(colorLabel);
    }];
    
    // Edit button
    UIButton *editButton = [[UIButton alloc] init];
    [editButton setImage:[UIImage systemImageNamed:@"pencil"] forState:UIControlStateNormal];
    editButton.tintColor = ParrotTextLightGray;
    [editButton addTarget:self action:@selector(editButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:editButton];
    self.editButton = editButton;
    [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView).offset(-16);
        make.top.equalTo(self.containerView).offset(16);
        make.width.height.mas_equalTo(24);
    }];
    
    // Delete button
    UIButton *deleteButton = [[UIButton alloc] init];
    [deleteButton setImage:[UIImage systemImageNamed:@"trash"] forState:UIControlStateNormal];
    deleteButton.tintColor = ParrotIconDelete;
    [deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:deleteButton];
    self.deleteButton = deleteButton;
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(editButton.mas_left).offset(-8);
        make.top.equalTo(self.containerView).offset(16);
        make.width.height.mas_equalTo(24);
    }];
}

- (void)setupEmptyStateView {
    // Empty state view
    UIView *emptyStateView = [[UIView alloc] init];
    emptyStateView.backgroundColor = [UIColor clearColor];
    emptyStateView.hidden = YES; // Initially hidden
    [self.containerView addSubview:emptyStateView];
    self.emptyStateView = emptyStateView;
    [emptyStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    
    // Empty state icon
    UIImageView *emptyIconView = [[UIImageView alloc] init];
    UIImage *emptyIcon = [UIImage systemImageNamed:@"plus.circle"];
    emptyIcon = [emptyIcon imageWithTintColor:ParrotTextLightGray renderingMode:UIImageRenderingModeAlwaysOriginal];
    emptyIconView.image = emptyIcon;
    [emptyStateView addSubview:emptyIconView];
    [emptyIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(emptyStateView);
        make.centerY.equalTo(emptyStateView).offset(-10);
        make.width.height.mas_equalTo(40);
    }];
    
    // Empty state label
    UILabel *emptyStateLabel = [[UILabel alloc] init];
    emptyStateLabel.text = @"Add Your Parrot";
    emptyStateLabel.textColor = ParrotTextMediumGray;
    emptyStateLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    emptyStateLabel.textAlignment = NSTextAlignmentCenter;
    [emptyStateView addSubview:emptyStateLabel];
    self.emptyStateLabel = emptyStateLabel;
    [emptyStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emptyIconView.mas_bottom).offset(8);
        make.centerX.equalTo(emptyStateView);
    }];
    
    // Add parrot button
    UIButton *addParrotButton = [[UIButton alloc] init];
    [addParrotButton addTarget:self action:@selector(addParrotButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [emptyStateView addSubview:addParrotButton];
    self.addParrotButton = addParrotButton;
    [addParrotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(emptyStateView);
    }];
}

- (void)loadParrotData {
    ParrotDataManager *dataManager = [ParrotDataManager sharedManager];
    self.currentParrotInfo = [dataManager getCurrentUserMainParrot];
    
    [self updateUI];
}

- (void)updateUI {
    BOOL hasParrotInfo = (self.currentParrotInfo != nil);
    
    // Show/hide appropriate views
    self.parrotImageView.hidden = !hasParrotInfo;
    self.nameLabel.hidden = !hasParrotInfo;
    self.breedLabel.hidden = !hasParrotInfo;
    self.colorLabel.hidden = !hasParrotInfo;
    self.ageLabel.hidden = !hasParrotInfo;
    self.editButton.hidden = !hasParrotInfo;     // Hide edit button when no parrot info
    self.deleteButton.hidden = !hasParrotInfo;   // Hide delete button when no parrot info
    self.emptyStateView.hidden = hasParrotInfo;
    
    if (hasParrotInfo) {
        [self updateParrotInfoDisplay];
    }
}

- (void)updateParrotInfoDisplay {
    if (!self.currentParrotInfo) return;
    
    self.nameLabel.text = self.currentParrotInfo.name ?: @"Unknown";
    self.breedLabel.text = self.currentParrotInfo.breed ?: @"Unknown Breed";
    self.colorLabel.text = self.currentParrotInfo.color ?: @"Unknown";
    
    if (self.currentParrotInfo.birthDate) {
        NSInteger age = [self calculateAgeFromBirthDate:self.currentParrotInfo.birthDate];
        if (age == 1) {
            self.ageLabel.text = @"1 year";
        } else {
            self.ageLabel.text = [NSString stringWithFormat:@"%ld years", (long)age];
        }
    } else {
        self.ageLabel.text = @"Unknown age";
    }
    
    // Load parrot photo if available
    if (self.currentParrotInfo.photoPath && self.currentParrotInfo.photoPath.length > 0) {
        // 构建完整的文件路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:self.currentParrotInfo.photoPath];
        
        UIImage *parrotImage = [UIImage imageWithContentsOfFile:fullPath];
        if (parrotImage) {
            self.parrotImageView.image = parrotImage;
        }
    }
}

- (void)addParrotButtonTapped {
    NSLog(@"Add parrot button tapped");
    // TODO: Show add parrot form
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAddParrotForm" object:nil];
}

- (void)editButtonTapped {
    NSLog(@"Edit parrot button tapped");
    // TODO: Show edit parrot form
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowEditParrotForm" object:self.currentParrotInfo];
}

- (void)deleteButtonTapped {
    NSLog(@"Delete parrot button tapped");
    
    UIAlertController *alertController = [UIAlertController 
        alertControllerWithTitle:@"Delete Parrot" 
        message:@"Are you sure you want to delete this parrot information? This action cannot be undone." 
        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction 
        actionWithTitle:@"Cancel" 
        style:UIAlertActionStyleCancel 
        handler:nil];
    
    UIAlertAction *deleteAction = [UIAlertAction 
        actionWithTitle:@"Delete" 
        style:UIAlertActionStyleDestructive 
        handler:^(UIAlertAction * _Nonnull action) {
            [self confirmDeleteParrot];
        }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    
    // Find the parent view controller to present alert
    UIViewController *parentVC = [self findParentViewController];
    if (parentVC) {
        [parentVC presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)confirmDeleteParrot {
    if (!self.currentParrotInfo) return;
    
    ParrotDataManager *dataManager = [ParrotDataManager sharedManager];
    BOOL success = [dataManager deleteParrotInfoWithId:self.currentParrotInfo.parrotId];
    
    if (success) {
        self.currentParrotInfo = nil;
        [self updateUI];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ParrotDataUpdated" object:nil];
    } else {
        NSLog(@"Failed to delete parrot info");
    }
}

- (UIViewController *)findParentViewController {
    UIResponder *responder = self;
    while (responder) {
        responder = [responder nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

- (void)updateParrotInfo:(NSDictionary *)parrotInfo {
    if (parrotInfo[@"name"]) {
        self.nameLabel.text = parrotInfo[@"name"];
    }
    
    if (parrotInfo[@"breed"]) {
        self.breedLabel.text = parrotInfo[@"breed"];
    }
    
    if (parrotInfo[@"color"]) {
        self.colorLabel.text = parrotInfo[@"color"];
    }
    
    if (parrotInfo[@"photo"]) {
        self.parrotImageView.image = parrotInfo[@"photo"];
    }
    
    if (parrotInfo[@"birthDate"]) {
        NSDate *birthDate = parrotInfo[@"birthDate"];
        NSInteger age = [self calculateAgeFromBirthDate:birthDate];
        if (age == 1) {
            self.ageLabel.text = @"1 year";
        } else {
            self.ageLabel.text = [NSString stringWithFormat:@"%ld years", (long)age];
        }
    }
}

- (NSInteger)calculateAgeFromBirthDate:(NSDate *)birthDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:birthDate toDate:[NSDate date] options:0];
    return components.year;
}

@end
