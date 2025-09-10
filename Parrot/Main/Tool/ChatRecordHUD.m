//
//  ChatRecordHUD.m
//  Kovela
//
//  Created by WCF on 2025/9/1.
//

#import "ChatRecordHUD.h"

@interface ChatRecordHUD ()
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, copy) void(^onTapEnd)(void);
@property (nonatomic, strong) UIView *maskView;
@end

@implementation ChatRecordHUD

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, 180, 180)]) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
        self.layer.cornerRadius = 20;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
        // 添加遮罩层
        self.maskView = [[UIView alloc] init];
        self.maskView.backgroundColor = [UIColor clearColor];
        self.maskView.userInteractionEnabled = YES;
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 180, 30)];
        _durationLabel.textColor = [UIColor blackColor];
        _durationLabel.font = [UIFont monospacedDigitSystemFontOfSize:22 weight:UIFontWeightMedium];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.text = @"00:00";
        [self addSubview:_durationLabel];
        UIButton *endBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        endBtn.frame = CGRectMake(40, 130, 100, 36);
        [endBtn setTitle:@"End Record" forState:UIControlStateNormal];
        [endBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        endBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.3 alpha:1.0];
        endBtn.layer.cornerRadius = 18;
        [endBtn addTarget:self action:@selector(tapToEnd) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:endBtn];
    }
    return self;
}
- (void)showInView:(UIView *)view {
    // 重置时间显示
    self.durationLabel.text = @"00:00";
    
    // 添加遮罩层
    self.maskView.frame = view.bounds;
    [view addSubview:self.maskView];
    
    self.center = view.center;
    self.alpha = 0;
    [view addSubview:self];
    [UIView animateWithDuration:0.18 animations:^{ self.alpha = 1; }];
}
- (void)dismiss {
    [UIView animateWithDuration:0.18 animations:^{ self.alpha = 0; }
                     completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self removeFromSuperview];
    }];
}
- (void)updateDuration:(NSTimeInterval)duration {
    NSInteger sec = (NSInteger)duration;
    self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", sec/60, sec%60];
}
- (void)tapToEnd { if (self.onTapEnd) self.onTapEnd(); }
- (void)setOnTapEnd:(void (^)(void))onTapEnd { _onTapEnd = [onTapEnd copy]; }

@end
