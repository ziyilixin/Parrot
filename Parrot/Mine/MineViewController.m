//
//  MineViewController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "MineViewController.h"
#import "MineHeadView.h"
#import "MineCell.h"
#import "WalletViewController.h"
#import "LoginViewController.h"
#import "ParrotDataManager.h"
#import "DiagnosisManager.h"
#import "FreeUsageManager.h"

@interface MineViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MineHeadView *headView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger availableCoins;
@end

static NSString * const mineCellId = @"MineCell";
static NSString * const headViewId = @"MineHeadView";

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getUserCoins];
}

- (void)initializeUI {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
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
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, ShowDiff+49+20, 0);
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    CGFloat headH = kStatusBarHeight + 20 + 100 + 80;
    MineHeadView *headView = [[MineHeadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, headH)];
    self.headView = headView;
    self.tableView.tableHeaderView = self.headView;
    
    [self.tableView registerClass:[MineCell class] forCellReuseIdentifier:mineCellId];
}

- (void)getUserCoins {
    [SVProgressHUD showLoading];
    [UserRepository getUserCoinsWithCompletion:^(NSInteger availableCoins, BOOL isSuccess) {
        [SVProgressHUD dismiss];
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.availableCoins = availableCoins;
                [self.tableView reloadData];
            });
        }
    } completionHandler:^{
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineCell *cell = [tableView dequeueReusableCellWithIdentifier:mineCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dict = self.dataArray[indexPath.row];
    if (indexPath.row == 0) {
        cell.coinLabel.hidden = NO;
        cell.coinLabel.text = [NSString stringWithFormat:@"%ld coins",(long)self.availableCoins];
    }
    else {
        cell.coinLabel.hidden = YES;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.item) {
        case 0: {
            WalletViewController *walletVC = [[WalletViewController alloc] init];
            walletVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:walletVC animated:YES];
        } break;
        case 1: {
            NSString *privacy = LFAppLink.privacy_url;
            NSURL *url = [NSURL URLWithString:privacy];
            if (!url) { return; }

            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                // Can open URL
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                // Cannot open URL
                NSLog(@"Cannot open this link");
            }
        } break;
        case 2: {
            NSString *userService = LFAppLink.terms_url;
            NSURL *url = [NSURL URLWithString:userService];
            if (!url) { return; }

            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                // Can open URL
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                // Cannot open URL
                NSLog(@"Cannot open this link");
            }
        } break;
        case 3: {
            [SVProgressHUD showLoading];
            [UserRepository logoutWithCompletion:^(BOOL isSuccess) {
                [SVProgressHUD dismiss];
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        LoginViewController *loginVC = [[LoginViewController alloc] init];
                        [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
                    });
                }
            } completionHandler:^{
                [SVProgressHUD dismiss];
            }];
        } break;
        case 4: {
            // Show delete account confirmation dialog
            [self showDeleteAccountConfirmAlert];
        } break;
        default: {
            
        } break;
    }
}

#pragma mark - Delete Account Confirmation

- (void)showDeleteAccountConfirmAlert {
    UIAlertController *alertController = [UIAlertController 
        alertControllerWithTitle:@"Delete Account" 
        message:@"Are you sure you want to delete your account?\n\nThis action will permanently delete all your data and cannot be undone." 
        preferredStyle:UIAlertControllerStyleAlert];
    
    // Cancel button
    UIAlertAction *cancelAction = [UIAlertAction 
        actionWithTitle:@"Cancel" 
        style:UIAlertActionStyleCancel 
        handler:nil];
    
    // Delete button - using destructive style
    UIAlertAction *deleteAction = [UIAlertAction 
        actionWithTitle:@"Delete" 
        style:UIAlertActionStyleDestructive 
        handler:^(UIAlertAction * _Nonnull action) {
            [self executeDeleteAccount];
        }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)executeDeleteAccount {
    [SVProgressHUD showLoading];
    [UserRepository deleteAccountWithCompletion:^(BOOL isSuccess) {
        [SVProgressHUD dismiss];
        if (isSuccess) {
            // After successful account deletion, remove all local user data
            [self cleanupLocalUserData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
            });
        }
    } completionHandler:^{
        [SVProgressHUD dismiss];
    }];
}

- (void)cleanupLocalUserData {
    NSString *userId = [LFWebData shared].userId;
    if (!userId || userId.length == 0) {
        NSLog(@"No user ID found for cleanup");
        return;
    }
    
    NSLog(@"Starting cleanup of local data for user: %@", userId);
    
    // 删除鹦鹉信息
    BOOL parrotCleanupSuccess = [[ParrotDataManager sharedManager] deleteAllParrotInfoForUser:userId];
    if (parrotCleanupSuccess) {
        NSLog(@"Successfully cleaned up parrot data");
    } else {
        NSLog(@"Failed to clean up parrot data");
    }
    
    // 删除诊断历史记录
    BOOL diagnosisCleanupSuccess = [[DiagnosisManager sharedManager] deleteAllDiagnosisRecordsForUser:userId];
    if (diagnosisCleanupSuccess) {
        NSLog(@"Successfully cleaned up diagnosis data");
    } else {
        NSLog(@"Failed to clean up diagnosis data");
    }
    
    // 删除免费次数记录
    BOOL freeUsageCleanupSuccess = [[FreeUsageManager sharedManager] deleteFreeUsageForUser:userId];
    if (freeUsageCleanupSuccess) {
        NSLog(@"Successfully cleaned up free usage data");
    } else {
        NSLog(@"Failed to clean up free usage data");
    }
    
    NSLog(@"Local data cleanup completed for user: %@", userId);
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat cornerRadius = 12.0;
//    cell.layer.cornerRadius = cornerRadius;
//    cell.layer.masksToBounds = YES;
//
//    NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
//
//    CACornerMask maskedCorners = 0;
//
//    if (indexPath.row == 0) {
//        maskedCorners |= kCALayerMinXMinYCorner;
//        maskedCorners |= kCALayerMaxXMinYCorner;
//    }
//
//    if (indexPath.row == numberOfRows - 1) {
//        maskedCorners |= kCALayerMinXMaxYCorner;
//        maskedCorners |= kCALayerMaxXMaxYCorner;
//    }
//
//    if (@available(iOS 11.0, *)) {
//        cell.layer.maskedCorners = maskedCorners;
//    }
//}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:
                      @{@"icon":@"storefront",@"title":@"Store"},
                        @{@"icon":@"hand.raised",@"title":@"Privacy Policy"},
                        @{@"icon":@"doc.text",@"title":@"Terms Of Service"},
                        @{@"icon":@"rectangle.portrait.and.arrow.right",@"title":@"Sign Out"},
                        @{@"icon":@"trash",@"title":@"Delete Account"},
                      nil];
    }
    return _dataArray;
}

@end
