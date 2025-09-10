//
//  MineCoinCell.m
//  Parrot
//
//  Created by WCF on 2025/9/8.
//

#import "MineCoinCell.h"

@interface MineCoinCell ()
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *originPriceLabel;
@property (nonatomic, strong) UIButton *declineButton;
@property (nonatomic, strong) UIButton *priceButton;
@property (nonatomic, strong) UIButton *promotionButton;
@end

@implementation MineCoinCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = ColorFFFFFF;
        bgView.layer.masksToBounds = YES;
        bgView.layer.cornerRadius = 16;
        // Add subtle shadow for depth
        bgView.layer.shadowColor = [UIColor blackColor].CGColor;
        bgView.layer.shadowOffset = CGSizeMake(0, 2);
        bgView.layer.shadowRadius = 8;
        bgView.layer.shadowOpacity = 0.1;
        bgView.layer.masksToBounds = NO;
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        // Inner container for content with proper masking
        UIView *contentContainer = [[UIView alloc] init];
        contentContainer.backgroundColor = [UIColor clearColor];
        contentContainer.layer.masksToBounds = YES;
        contentContainer.layer.cornerRadius = 16;
        [bgView addSubview:contentContainer];
        [contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(bgView);
        }];
        
        UIButton *promotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [promotionButton setTitle:@"Promotion" forState:UIControlStateNormal];
        [promotionButton setTitleColor:ColorFFFFFF forState:UIControlStateNormal];
        promotionButton.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
        promotionButton.backgroundColor = ParrotIconDelete; // Use consistent red color
        promotionButton.userInteractionEnabled = NO;
        promotionButton.hidden = YES;
        [contentContainer addSubview:promotionButton];
        [promotionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(contentContainer);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(30);
        }];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 60, 30) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = CGRectMake(0, 0, 60, 30);
        maskLayer.path = maskPath.CGPath;
        promotionButton.layer.mask = maskLayer;
        self.promotionButton = promotionButton;
        
        UIImageView *coinImageView = [[UIImageView alloc] init];
        coinImageView.image = ImageNamed(@"login_logo");
        coinImageView.layer.masksToBounds = YES;
        coinImageView.layer.cornerRadius = 12;
        [contentContainer addSubview:coinImageView];
        [coinImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(contentContainer);
            make.top.equalTo(contentContainer).offset(16);
            make.width.height.mas_equalTo(60);
        }];
        
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.textColor = ParrotTextDarkGray;
        numLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
        [contentContainer addSubview:numLabel];
        self.numLabel = numLabel;
        [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(coinImageView.mas_bottom).offset(12);
            make.centerX.equalTo(contentContainer);
        }];
        
        UIButton *priceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [priceButton setTitleColor:ColorFFFFFF forState:UIControlStateNormal];
        priceButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        priceButton.userInteractionEnabled = NO;
        priceButton.backgroundColor = ParrotPrimaryGreen; // Use consistent green color
        priceButton.layer.masksToBounds = YES;
        priceButton.layer.cornerRadius = 18;
        [contentContainer addSubview:priceButton];
        [priceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.numLabel.mas_bottom).offset(16);
            make.centerX.equalTo(contentContainer);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(36);
        }];
        self.priceButton = priceButton;
    }
    return self;
}

- (void)setGood:(CoinGoodEntity *)good {
    _good = good;
    
    if (_good.isPromotion) {
        self.promotionButton.hidden = NO;
    }
    else {
        self.promotionButton.hidden = YES;
    }
    
    self.numLabel.text = [NSString stringWithFormat:@"%ld", (long)_good.exchangeCoin];
    [self.priceButton setTitle:[NSString stringWithFormat:@"$%.2f",_good.price] forState:UIControlStateNormal];
}
@end
