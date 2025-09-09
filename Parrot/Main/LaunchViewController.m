//
//  LaunchViewController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "LaunchViewController.h"
#import "NetworkPermissionManager.h"
#import "CustomLoadingView.h"
#import "LoginViewController.h"
#import "MainTabBarController.h"

@interface LaunchViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, assign) NSInteger loginRetryCount;
@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Network Error";
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:25];
    titleLabel.hidden = YES;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [refreshButton setTitleColor:ColorFFFFFF forState:UIControlStateNormal];
    refreshButton.titleLabel.font = [UIFont systemFontOfSize:30];
    refreshButton.backgroundColor = Color000000;
    refreshButton.layer.masksToBounds = YES;
    refreshButton.layer.cornerRadius = 12;
    [refreshButton addTarget:self action:@selector(onClickRefresh:) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.hidden = YES;
    [self.view addSubview:refreshButton];
    self.refreshButton = refreshButton;
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(60);
    }];
    
    self.loginRetryCount = 0;
    
    NetworkPermissionManager *manager = [NetworkPermissionManager sharedInstance];
    if (!manager.hasNetworkPermission) {
        __weak typeof(self) weakSelf = self;
        [manager checkNetworkPermissionWithCompletion:^(BOOL granted) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return; // 防止self已释放
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf.titleLabel.hidden = YES;
                    strongSelf.refreshButton.hidden = YES;
                    [strongSelf loginOatuth];
                });
            }
        }];
    }
}

- (void)loginOatuth {
    [CustomLoadingView show];
    
    __weak typeof(self) weakSelf = self;
    [UserRepository getConfigAndStrategyInfoWithComletion:^(BOOL isReviewPkg, BOOL isLogin) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        [CustomLoadingView hide];
        strongSelf.loginRetryCount = 0;
        if (isLogin) {
            if (!isReviewPkg) {
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[LFWebController alloc] init]];
                [LFRouter switchRootViewController:nav];
                return;
            }
            
            MainTabBarController *tabBarVC = [[MainTabBarController alloc] init];
            [LFRouter switchRootViewController:tabBarVC];
        } else {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            [LFRouter switchRootViewController:loginVC];
        }
    } onFailed:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        strongSelf.loginRetryCount++;
        if (strongSelf.loginRetryCount < 5) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf loginOatuth];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CustomLoadingView hide];
                strongSelf.titleLabel.hidden = NO;
                strongSelf.refreshButton.hidden = NO;
            });
        }
    }];
}

- (void)onClickRefresh:(UIButton *)button {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        strongSelf.titleLabel.hidden = YES;
        strongSelf.refreshButton.hidden = YES;
        [strongSelf loginOatuth];
    });
}

- (void)dealloc {
    NSLog(@"LaunchViewController dealloc");
}

@end
