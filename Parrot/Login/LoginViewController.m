//
//  LoginViewController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "LoginViewController.h"
#import "AgreementAlertView.h"
#import "MainTabBarController.h"
#import "AppleSignInManager.h"

@interface LoginViewController ()
@property (nonatomic, strong) UIButton *imageBtn;
@property (nonatomic, strong) UIButton *bigSelectButton;
@property (nonatomic, strong) UIButton *protocBtn;
@property (nonatomic, strong) UIButton *securetBtn;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeUI];
}

- (void)initializeUI {
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.image = ImageNamed(@"login_bg");
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.clipsToBounds = YES;
    //bgImageView.backgroundColor = Color000000;
    [self.view addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor colorWithHexString:@"#262626" alpha:1.0];
    titleLabel.userInteractionEnabled = YES;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(30);
    }];

    // 构建富文本
    NSString *str = @"I agree to the User Agreement and Privacy Policy ";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];

    // 找到协议的range
    NSRange userRange = [str rangeOfString:@" User Agreement "];
    NSRange privacyRange = [str rangeOfString:@" Privacy Policy "];

    // 设置灰色下划线
    UIColor *underlineColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1.0];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:userRange];
    [attrStr addAttribute:NSUnderlineColorAttributeName value:underlineColor range:userRange];
    [attrStr addAttribute:NSForegroundColorAttributeName value:underlineColor range:userRange];

    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:privacyRange];
    [attrStr addAttribute:NSUnderlineColorAttributeName value:underlineColor range:privacyRange];
    [attrStr addAttribute:NSForegroundColorAttributeName value:underlineColor range:privacyRange];

    titleLabel.attributedText = attrStr;

    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imageBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    // 使用系统选择图标，设置颜色为 #262626
    UIImage *normalImage = [UIImage systemImageNamed:@"circle"];
    UIImage *selectedImage = [UIImage systemImageNamed:@"checkmark.circle.fill"];
    
    // 设置图标颜色
    UIColor *iconColor = [UIColor colorWithRed:0x26/255.0 green:0x26/255.0 blue:0x26/255.0 alpha:1.0];
    normalImage = [normalImage imageWithTintColor:iconColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    selectedImage = [selectedImage imageWithTintColor:iconColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [imageBtn setImage:normalImage forState:UIControlStateNormal];
    [imageBtn setImage:selectedImage forState:UIControlStateSelected];
    [imageBtn addTarget:self action:@selector(protocolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageBtn];
    self.imageBtn = imageBtn;
    [imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.centerY.equalTo(titleLabel);
        make.right.mas_equalTo(titleLabel.mas_left).offset(-5);
    }];

    //扩大按钮点击区域
    UIButton *bigSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bigSelectButton addTarget:self action:@selector(onClickBigSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bigSelectButton];
    self.bigSelectButton = bigSelectButton;
    [self.bigSelectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageBtn).offset(-10);
        make.centerY.equalTo(self.imageBtn);
        make.right.equalTo(titleLabel.mas_left).offset(30);
        make.height.mas_equalTo(40);
    }];

    UIButton *msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    msgBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [msgBtn addTarget:self action:@selector(loadMsgVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:msgBtn];
    self.protocBtn = msgBtn;
    [msgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(titleLabel.mas_right).offset(-90);
        make.width.mas_equalTo(90);
    }];

    UIButton *securetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    securetBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [securetBtn addTarget:self action:@selector(loadSecuret) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:securetBtn];
    self.securetBtn = securetBtn;
    [securetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(titleLabel.mas_right);
        make.width.mas_equalTo(70);
    }];

    if ([UserDefaults boolForKey:Agreement]) {
        self.imageBtn.selected = YES;
    }
    else {
        self.imageBtn.selected = NO;
    }
    
    CGFloat appleH = (kScreenWidth - 48*2)*52/280;
    UIButton *appleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [appleButton setTitle:@"Sign in with Apple" forState:UIControlStateNormal];
    [appleButton setTitleColor:ColorFFFFFF forState:UIControlStateNormal];
    appleButton.titleLabel.font = [UIFont fontWithName:PingFangRegular size:20];
    [appleButton setImage:ImageNamed(@"login_apple") forState:UIControlStateNormal];
    appleButton.backgroundColor = [UIColor colorWithHexString:@"#262626" alpha:1.0];
    appleButton.layer.masksToBounds = YES;
    appleButton.layer.cornerRadius = 26.0;
    [appleButton addTarget:self action:@selector(appleLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:appleButton];
    [appleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(titleLabel.mas_top).offset(-45);
        make.height.mas_equalTo(appleH);
        make.left.equalTo(self.view).offset(48);
        make.right.equalTo(self.view).offset(-48);
    }];
    [appleButton horizontalCenterImageAndTitleWithSpacing:4.0];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setTitle:@"Quick Login" forState:UIControlStateNormal];
    [loginButton setTitleColor:ColorFFFFFF forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont fontWithName:PingFangRegular size:20];
    [loginButton setImage:ImageNamed(@"login_quick") forState:UIControlStateNormal];
    loginButton.backgroundColor = [UIColor colorWithHexString:@"#F476FF" alpha:1.0];
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = 26.0;
    [loginButton addTarget:self action:@selector(onClickQuickLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(appleButton.mas_top).offset(-28);
        make.height.equalTo(appleButton);
        make.left.equalTo(self.view).offset(48);
        make.right.equalTo(self.view).offset(-48);
    }];
    [loginButton horizontalCenterImageAndTitleWithSpacing:4.0];
}

- (void)onClickQuickLogin:(UIButton *)button {
    if (!self.imageBtn.selected) {
        [AgreementAlertView showWithCompletion:^(BOOL agreed) {
            if (agreed) {
                [self onClickBigSelect:self.bigSelectButton];
                // 用户同意协议，继续登录流程
                [self executeLogin];
            }
        }];
        return;
    }
    
    //执行登录
    [self executeLogin];
}

// 执行登录操作
- (void)executeLogin {
    [UserRepository loginOauthWithOauthType:@"4" token:@"" comletion:^(BOOL isReviewPkg) {
        if (!isReviewPkg) {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[LFWebController alloc] init]];
            [LFRouter switchRootViewController:nav];
            return;
        }
        
        MainTabBarController *mainTabBarVC = [[MainTabBarController alloc] init];
        [LFRouter switchRootViewController:mainTabBarVC];
    } onFailed:^{
        [SVProgressHUD showError:@"Login failed. Please try again"];
    } completionHandler:^{
        
    }];
}

- (void)appleLogin:(UIButton *)button {
    if (!self.imageBtn.selected) {
        [AgreementAlertView showWithCompletion:^(BOOL agreed) {
            if (agreed) {
                [self onClickBigSelect:self.bigSelectButton];
                // 用户同意协议，继续登录流程
                [self executeAppleLogin];
            }
        }];
        return;
    }
    
    //执行苹果登录
    [self executeAppleLogin];
}

// 执行苹果登录操作
- (void)executeAppleLogin {
    [[AppleSignInManager sharedInstance] handleAppleSignInWithCompletion:^(AppleSignInState state, NSString *identityToken, NSString *email, NSString *fullName, NSError *error) {
        switch (state) {
            case AppleSignInStateSuccess:
                // 处理登录成功
                [self handleAppleLoginSuccessWithIdentityToken:identityToken email:email fullName:fullName];
                break;
                
            case AppleSignInStateFailed:
                // 处理登录失败
                [SVProgressHUD showError:error.localizedDescription];
                break;
                
            case AppleSignInStateCancelled:
                // 用户取消登录，不需要特殊处理
                break;
                
            case AppleSignInStateNotSupport:
                // 设备不支持苹果登录
                [SVProgressHUD showError:@"Your device does not support Apple Sign In"];
                break;
        }
    }];
}

/**
* 处理苹果登录成功
*/
- (void)handleAppleLoginSuccessWithIdentityToken:(NSString *)identityToken email:(NSString *)email fullName:(NSString *)fullName {
    [UserRepository loginOauthWithOauthType:@"3" token:identityToken comletion:^(BOOL isReviewPkg) {
        if (!isReviewPkg) {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[LFWebController alloc] init]];
            [LFRouter switchRootViewController:nav];
            return;
        }
        
        MainTabBarController *mainTabBarVC = [[MainTabBarController alloc] init];
        [LFRouter switchRootViewController:mainTabBarVC];
    } onFailed:^{
        [SVProgressHUD showError:@"Login failed. Please try again"];
    } completionHandler:^{
        
    }];
}

- (void)protocolBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    self.imageBtn = btn;
    
    if (self.imageBtn.selected) {
        [UserDefaults setBool:YES forKey:Agreement];
        [UserDefaults synchronize];
    }
    else {
        [UserDefaults setBool:NO forKey:Agreement];
        [UserDefaults synchronize];
    }
}

- (void)onClickBigSelect:(UIButton *)button {
    [self protocolBtnClick:self.imageBtn];
}

//服务条款
- (void)loadMsgVC {
    NSLog(@"服务条款");
    NSString *userService = LFAppLink.terms_url;
    NSURL *url = [NSURL URLWithString:userService];
    if (!url) { return; }

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        // 可以打开URL
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        // 无法打开URL
        NSLog(@"无法打开该链接");
    }
}

//隐私政策
- (void)loadSecuret {
    NSLog(@"隐私政策");
    NSString *privacy = LFAppLink.privacy_url;
    NSURL *url = [NSURL URLWithString:privacy];
    if (!url) { return; }

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        // 可以打开URL
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        // 无法打开URL
        NSLog(@"无法打开该链接");
    }
}

@end
