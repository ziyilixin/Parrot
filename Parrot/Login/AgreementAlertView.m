//
//  AgreementAlertView.m
//  NY
//
//  Created by WCF on 2025/5/13.
//

#import "AgreementAlertView.h"

@interface AgreementAlertView () <UITextViewDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, copy) void(^completionBlock)(BOOL agreed);
@end

@implementation AgreementAlertView

+ (void)showWithCompletion:(void(^)(BOOL agreed))completion {
    AgreementAlertView *alertView = [[AgreementAlertView alloc] init];
    alertView.completionBlock = completion;
    [alertView show];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 背景遮罩
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.frame = [UIScreen mainScreen].bounds;
    
    // 容器视图
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 12;
    self.containerView.clipsToBounds = YES;
    [self addSubview:self.containerView];
    
    // 消息文本视图 - 使用UITextView
    self.messageTextView = [[UITextView alloc] init];
    self.messageTextView.editable = NO;
    self.messageTextView.scrollEnabled = NO;
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.textAlignment = NSTextAlignmentCenter;
    self.messageTextView.textColor = [UIColor blackColor];
    self.messageTextView.delegate = self;
    self.messageTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.messageTextView.linkTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0],
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
    };
    // 确保链接可以被点击
    self.messageTextView.selectable = YES;
    [self.containerView addSubview:self.messageTextView];
    
    // 设置富文本内容
    NSString *text = @"By using our application, you agree to our User Agreement and Privacy policy";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 设置整个文本的字体和颜色 - 调整字体大小
    UIFont *textFont = [UIFont systemFontOfSize:18];
    [attrStr addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, text.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, text.length)];
    
    // 找到"User Agreement"和"Privacy policy"的范围
    NSRange userAgreementRange = [text rangeOfString:@"User Agreement"];
    NSRange privacyPolicyRange = [text rangeOfString:@"Privacy policy"];
    
    // 设置链接属性
    UIColor *linkColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
    
    // User Agreement 链接 - 使用真实的用户协议URL
    NSString *userService = LFAppLink.terms_url;
    [attrStr addAttribute:NSLinkAttributeName value:userService range:userAgreementRange];
    [attrStr addAttribute:NSForegroundColorAttributeName value:linkColor range:userAgreementRange];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:userAgreementRange];
    
    // Privacy policy 链接 - 使用真实的隐私政策URL
    NSString *privacy = LFAppLink.privacy_url;
    [attrStr addAttribute:NSLinkAttributeName value:privacy range:privacyPolicyRange];
    [attrStr addAttribute:NSForegroundColorAttributeName value:linkColor range:privacyPolicyRange];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:privacyPolicyRange];
    
    self.messageTextView.attributedText = attrStr;
    
    // 确保字体设置生效
    self.messageTextView.font = textFont;
    
    // Cancel按钮
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.cancelButton.layer.cornerRadius = 8;
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.cancelButton];
    
    // Agree按钮
    self.agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.agreeButton setTitle:@"Agree" forState:UIControlStateNormal];
    [self.agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.agreeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.agreeButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
    self.agreeButton.layer.cornerRadius = 8;
    [self.agreeButton addTarget:self action:@selector(agreeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.agreeButton];
    
    // 设置约束
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.equalTo(self).offset(40);
        make.right.equalTo(self).offset(-40);
    }];
    
    [self.messageTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(20);
        make.left.equalTo(self.containerView).offset(20);
        make.right.equalTo(self.containerView).offset(-20);
        make.bottom.lessThanOrEqualTo(self.cancelButton.mas_top).offset(-20);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageTextView.mas_bottom).offset(20);
        make.left.equalTo(self.containerView).offset(20);
        make.bottom.equalTo(self.containerView).offset(-20);
        make.height.mas_equalTo(44);
    }];
    
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageTextView.mas_bottom).offset(20);
        make.left.equalTo(self.cancelButton.mas_right).offset(10);
        make.right.equalTo(self.containerView).offset(-20);
        make.bottom.equalTo(self.containerView).offset(-20);
        make.width.equalTo(self.cancelButton);
        make.height.equalTo(self.cancelButton);
    }];
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    // 动画显示
    self.alpha = 0;
    self.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        self.containerView.transform = CGAffineTransformIdentity;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)textView:(UITextView *)textView didSelectLinkWithURL:(NSURL *)url {
    // 检查是否是用户协议链接
    if ([url.absoluteString isEqualToString:LFAppLink.terms_url]) {
        [self openUserAgreement];
    }
    // 检查是否是隐私政策链接
    else if ([url.absoluteString isEqualToString:LFAppLink.privacy_url]) {
        [self openPrivacyPolicy];
    } else {
        NSLog(@"未知链接: %@", url.absoluteString);
    }
}

- (void)openUserAgreement {
    NSString *userService = LFAppLink.terms_url;
    NSURL *url = [NSURL URLWithString:userService];
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        NSLog(@"无法打开用户协议URL: %@", userService);
    }
}

- (void)openPrivacyPolicy {
    NSString *privacy = LFAppLink.privacy_url;
    NSURL *url = [NSURL URLWithString:privacy];
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        NSLog(@"无法打开隐私政策URL: %@", privacy);
    }
}

- (void)cancelButtonTapped {
    if (self.completionBlock) {
        self.completionBlock(NO);
    }
    [self hide];
}

- (void)agreeButtonTapped {
    if (self.completionBlock) {
        self.completionBlock(YES);
    }
    [self hide];
}
@end
