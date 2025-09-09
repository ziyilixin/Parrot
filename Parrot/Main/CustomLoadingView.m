//
//  CustomLoadingView.m
//  Parrot
//
//  Created by WCF on 2025/9/1.
//

#import "CustomLoadingView.h"

@interface CustomLoadingView ()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSTimer *textTimer;
@property (nonatomic, assign) NSInteger tickCount;
@end

@implementation CustomLoadingView

static CustomLoadingView *_instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CustomLoadingView alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 创建背景视图
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    // 创建容器视图
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.layer.cornerRadius = 15;
    self.containerView.layer.masksToBounds = YES;
    
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.image = ImageNamed(@"common_launch");
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    
    // 创建加载指示器
    self.loadingImageView = [[UIImageView alloc] init];
    self.loadingImageView.image = [UIImage imageWithGIFNamed:@"Parrot"];
    self.loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 创建标签
    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.text = @"Preparing...";
    self.loadingLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.8];
    self.loadingLabel.font = [UIFont systemFontOfSize:14];
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    
    // 初始化计时器
    self.tickCount = 0;
}

- (void)updateLoadingText {
    self.tickCount++;
    NSArray *loadingTexts = @[@"Initializing...", @"Configuring...", @"Loading resources...", @"Preparing...", @"Almost ready..."];
    NSString *loadingText = loadingTexts[self.tickCount % loadingTexts.count];
    self.loadingLabel.text = loadingText;
}

+ (void)show {
    CustomLoadingView *loadingView = [CustomLoadingView sharedInstance];
    
    // 获取主窗口
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) {
        return;
    }
    
    // 如果已经显示，先移除
    if (loadingView.backgroundView.superview) {
        [loadingView.backgroundView removeFromSuperview];
    }
    
    // 添加背景视图到主窗口
    [keyWindow addSubview:loadingView.backgroundView];
    
    // 设置背景视图约束 - 覆盖整个屏幕
    [loadingView.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(keyWindow);
    }];
    
    // 添加容器视图到背景视图
    [loadingView.backgroundView addSubview:loadingView.containerView];
    
    // 设置容器视图约束 - 屏幕中央，固定尺寸
    [loadingView.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(loadingView.backgroundView);
    }];
    
    [loadingView.containerView addSubview:loadingView.bgImageView];
    [loadingView.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(loadingView.containerView);
    }];
    
    // 添加标签到容器视图
    [loadingView.containerView addSubview:loadingView.loadingLabel];
    
    // 设置标签约束 - loading下方
    [loadingView.loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(loadingView.containerView);
        make.bottom.equalTo(loadingView.containerView).offset(-ShowDiff-20);
    }];
    
    // 添加加载指示器到容器视图
    [loadingView.containerView addSubview:loadingView.loadingImageView];
    
    // 设置加载指示器约束 - logo下方中央
    [loadingView.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(loadingView.containerView);
        make.bottom.equalTo(loadingView.loadingLabel.mas_top).offset(-20);
        make.width.height.mas_equalTo(100);
    }];
    
    // 启动文字更新计时器
    loadingView.textTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:loadingView selector:@selector(updateLoadingText) userInfo:nil repeats:YES];
}

+ (void)hide {
    CustomLoadingView *loadingView = [CustomLoadingView sharedInstance];
    
    // 停止计时器
    if (loadingView.textTimer) {
        [loadingView.textTimer invalidate];
        loadingView.textTimer = nil;
    }
    
    // 移除背景视图
    [loadingView.backgroundView removeFromSuperview];
}

@end
