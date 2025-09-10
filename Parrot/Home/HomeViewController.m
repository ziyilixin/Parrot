//
//  HomeViewController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "HomeViewController.h"
#import "ParrotProfileView.h"
#import "DailyReminderView.h"
#import "ParrotDataManager.h"
#import "AddParrotViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@interface HomeViewController () <AddParrotViewControllerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ParrotProfileView *parrotProfileView;
@property (nonatomic, strong) DailyReminderView *dailyReminderView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self setupUI];
    [self setupNotifications];
    
    // Delay requesting ad tracking permission for better user experience
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self applyAdvertising];
    });
}

- (void)applyAdvertising {
    if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    NSLog(@"用户尚未做出选择");
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    NSLog(@"访问受限");
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                    NSLog(@"用户拒绝了授权");
                    break;
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    NSLog(@"用户授权成功，可以使用IDFA: %@", [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
                    break;
            }
        }];
    } else {
        NSString *idfaString = @"";
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            NSUUID *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier];
            idfaString = [idfa UUIDString];
            NSLog(@"用户允许追踪，IDFA: %@", idfaString);
        } else {
            NSLog(@"用户关闭了广告追踪");
        }

    }
}

- (void)setupUI {
    // Create elegant gradient background
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    
    // Use soft green gradient, fits parrot care app's natural theme
    UIColor *topColor = ParrotBgGradientTop; // Light green
    UIColor *bottomColor = ParrotBgGradientBottom; // Lighter green-white
    
    gradientLayer.colors = @[(__bridge id)topColor.CGColor, (__bridge id)bottomColor.CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(0.0, 1.0);
    
    UIView *bgView = [[UIView alloc] init];
    [bgView.layer addSublayer:gradientLayer];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // Ensure gradient layer adjusts correctly when view size changes
    dispatch_async(dispatch_get_main_queue(), ^{
        gradientLayer.frame = self.view.bounds;
    });
    
    // 滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, ShowDiff+49+20, 0);
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 内容视图
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:contentView];
    self.contentView = contentView;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    
    // 顶部安全区域占位
    UIView *topSpacerView = [[UIView alloc] init];
    topSpacerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:topSpacerView];
    [topSpacerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(contentView);
        make.height.mas_equalTo(kStatusBarHeight + 20);
    }];
    
    // 鹦鹉档案视图
    ParrotProfileView *parrotProfileView = [[ParrotProfileView alloc] init];
    [contentView addSubview:parrotProfileView];
    self.parrotProfileView = parrotProfileView;
    [parrotProfileView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topSpacerView.mas_bottom);
        make.left.right.equalTo(contentView);
    }];
    
    // 日常提醒视图
    DailyReminderView *dailyReminderView = [[DailyReminderView alloc] init];
    [contentView addSubview:dailyReminderView];
    self.dailyReminderView = dailyReminderView;
    [dailyReminderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(parrotProfileView.mas_bottom).offset(20);
        make.left.right.equalTo(contentView);
        make.height.mas_equalTo(140);
        make.bottom.equalTo(contentView).offset(-20);
    }];
    
    // Initialize database
    [[ParrotDataManager sharedManager] initializeDatabase];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAddParrotForm)
                                                 name:@"ShowAddParrotForm"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showEditParrotForm:)
                                                 name:@"ShowEditParrotForm"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parrotDataUpdated)
                                                 name:@"ParrotDataUpdated"
                                               object:nil];
}

- (void)showAddParrotForm {
    NSLog(@"Show add parrot form");
    
    AddParrotViewController *addVC = [[AddParrotViewController alloc] init];
    addVC.delegate = self;
    addVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)showEditParrotForm:(NSNotification *)notification {
    ParrotInfo *parrotInfo = notification.object;
    NSLog(@"Show edit parrot form for: %@", parrotInfo.name);
    // TODO: Present edit parrot form view controller
    [self showParrotFormWithParrotInfo:parrotInfo];
}

- (void)showParrotFormWithParrotInfo:(ParrotInfo *)parrotInfo {
    // For now, just show an alert as placeholder
    NSString *title = parrotInfo ? @"Edit Parrot" : @"Add Parrot";
    NSString *message = parrotInfo ? [NSString stringWithFormat:@"Edit %@'s information", parrotInfo.name] : @"Add your parrot's information";
    
    UIAlertController *alertController = [UIAlertController 
        alertControllerWithTitle:title 
        message:message 
        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction 
        actionWithTitle:@"OK" 
        style:UIAlertActionStyleDefault 
        handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)parrotDataUpdated {
    // Refresh the parrot profile view
    [self.parrotProfileView loadParrotData];
}

#pragma mark - AddParrotViewControllerDelegate

- (void)didAddParrotSuccessfully {
    // Refresh the parrot profile view
    [self.parrotProfileView loadParrotData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
