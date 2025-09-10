//
//  HomeViewController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "HomeViewController.h"
#import "ParrotProfileView.h"
#import "HealthDiagnosisView.h"
#import "ParrotDataManager.h"
#import "DiagnosisManager.h"
#import "DiagnosisDetailViewController.h"
#import "AddParrotViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@interface HomeViewController () <HealthDiagnosisViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ParrotProfileView *parrotProfileView;
@property (nonatomic, strong) HealthDiagnosisView *healthDiagnosisView;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Reload data from database every time the view appears
    [self.parrotProfileView loadParrotData];
    [self.healthDiagnosisView refreshData];
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
    
    // 健康诊断视图
    HealthDiagnosisView *healthDiagnosisView = [[HealthDiagnosisView alloc] init];
    healthDiagnosisView.delegate = self;
    [contentView addSubview:healthDiagnosisView];
    self.healthDiagnosisView = healthDiagnosisView;
    [healthDiagnosisView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(parrotProfileView.mas_bottom).offset(20);
        make.left.right.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-20);
    }];
    
    // Initialize databases
    [[ParrotDataManager sharedManager] initializeDatabase];
    [[DiagnosisManager sharedManager] initializeDatabase];
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
}

- (void)showAddParrotForm {
    NSLog(@"Show add parrot form");
    
    AddParrotViewController *addVC = [[AddParrotViewController alloc] init];
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
    AddParrotViewController *addVC = [[AddParrotViewController alloc] init];
    addVC.parrotInfoToEdit = parrotInfo; // 传递要编辑的鹦鹉信息
    addVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - AddParrotViewControllerDelegate

- (void)didAddParrotSuccessfully {
    // This method is no longer needed since we reload data in viewWillAppear
    // But keeping it for compatibility
}

#pragma mark - HealthDiagnosisViewDelegate

- (void)healthDiagnosisDidComplete {
    // Refresh the diagnosis history
    [self.healthDiagnosisView refreshData];
}

- (void)healthDiagnosisView:(HealthDiagnosisView *)view didSelectDiagnosisRecord:(DiagnosisRecord *)record {
    // 跳转到诊断详情页面
    DiagnosisDetailViewController *detailVC = [[DiagnosisDetailViewController alloc] initWithDiagnosisRecord:record];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
