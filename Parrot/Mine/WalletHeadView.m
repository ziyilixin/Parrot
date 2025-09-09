//
//  WalletHeadView.m
//  Photography
//
//  Created by WCF on 2025/9/8.
//

#import "WalletHeadView.h"

@implementation WalletHeadView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat coinH = (kScreenWidth - 38*2)*90/300;
        UIView *coinContainer = [[UIView alloc] init];
        coinContainer.backgroundColor = ColorFFFFFF;
        coinContainer.layer.masksToBounds = YES;
        coinContainer.layer.cornerRadius = 16;
        // Add subtle shadow for depth
        coinContainer.layer.shadowColor = [UIColor blackColor].CGColor;
        coinContainer.layer.shadowOffset = CGSizeMake(0, 2);
        coinContainer.layer.shadowRadius = 8;
        coinContainer.layer.shadowOpacity = 0.1;
        coinContainer.layer.masksToBounds = NO;
        [self addSubview:coinContainer];
        [coinContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(0);
            make.left.equalTo(self).offset(38);
            make.right.equalTo(self).offset(-38);
            make.height.mas_equalTo(coinH);
        }];
        
        UIImageView *cameraImageView = [[UIImageView alloc] init];
        cameraImageView.image = ImageNamed(@"login_logo");
        cameraImageView.layer.masksToBounds = YES;
        cameraImageView.layer.cornerRadius = 12;
        [coinContainer addSubview:cameraImageView];
        [cameraImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(coinContainer).offset(16);
            make.centerY.equalTo(coinContainer);
            make.width.height.mas_equalTo(60);
        }];
        
        UILabel *coinLabel = [[UILabel alloc] init];
        coinLabel.text = @"My Coins";
        coinLabel.textColor = ParrotTextDarkGray;
        coinLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        [coinContainer addSubview:coinLabel];
        [coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(coinContainer).offset(-20);
            make.top.equalTo(cameraImageView).offset(8);
        }];
        
        UILabel *coinNumLabel = [[UILabel alloc] init];
        coinNumLabel.textColor = ParrotCoinGreen;
        coinNumLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [coinContainer addSubview:coinNumLabel];
        self.coinNumLabel = coinNumLabel;
        [self.coinNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(coinLabel);
            make.bottom.equalTo(cameraImageView).offset(-8);
        }];
    }
    return self;
}
@end
