//
//  MineCell.m
//  Photography
//
//  Created by WCF on 2025/9/8.
//

#import "MineCell.h"

@interface MineCell ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        UIView *contV = [[UIView alloc] init];
        contV.backgroundColor = ColorFFFFFF;
        contV.layer.masksToBounds = YES;
        contV.layer.cornerRadius = 12.0;
        [self.contentView addSubview:contV];
        [contV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
        
        UIImageView *iconImageView = [[UIImageView alloc] init];
        [contV addSubview:iconImageView];
        self.iconImageView = iconImageView;
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(contV).offset(20);
            make.centerY.equalTo(contV);
            make.width.height.mas_equalTo(24);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = ParrotTextDarkGray; // Dark gray, softer
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium]; // Medium weight
        [contV addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(18);
            make.centerY.equalTo(contV);
        }];
        
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        UIImage *arrowIcon = [UIImage systemImageNamed:@"chevron.right"];
        UIColor *arrowColor = ParrotTextLightGray; // Medium gray, softer
        arrowIcon = [arrowIcon imageWithTintColor:arrowColor renderingMode:UIImageRenderingModeAlwaysOriginal];
        arrowImageView.image = arrowIcon;
        [self.contentView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-8);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(15);
        }];
        
        UILabel *coinLabel = [[UILabel alloc] init];
        coinLabel.textColor = ParrotCoinGreen; // Green, highlight coins
        coinLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]; // Semibold
        [contV addSubview:coinLabel];
        self.coinLabel = coinLabel;
        [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(arrowImageView.mas_left).offset(-11);
            make.centerY.equalTo(contV);
        }];
        
//        UIView *lineView = [[UIView alloc] init];
//        lineView.hidden = YES;
//        lineView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.1];
//        [self.contentView addSubview:lineView];
//        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(contV).offset(8);
//            make.right.equalTo(self.contentView).offset(-8);
//            make.bottom.equalTo(contV);
//            make.height.mas_equalTo(1.0);
//        }];
//        self.lineView = lineView;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.size.height -= 12;

    [super setFrame:frame];
}

- (void)setDict:(NSDictionary *)dict {
    _dict = dict;
    
    NSString *iconName = _dict[@"icon"];
    if (iconName && iconName.length > 0) {
        UIImage *systemIcon = [UIImage systemImageNamed:iconName];
        if (systemIcon) {
            UIColor *iconColor = [self getIconColorForTitle:_dict[@"title"]];
            systemIcon = [systemIcon imageWithTintColor:iconColor renderingMode:UIImageRenderingModeAlwaysOriginal];
            self.iconImageView.image = systemIcon;
        } else {
            // If system icon doesn't exist, use default icon
            self.iconImageView.image = [UIImage systemImageNamed:@"circle"];
        }
    } else {
        self.iconImageView.image = nil;
    }
    
    self.titleLabel.text = _dict[@"title"];
}

- (UIColor *)getIconColorForTitle:(NSString *)title {
    if ([title isEqualToString:@"Store"]) {
        return ParrotIconStore; // Blue - Store
    } else if ([title isEqualToString:@"Privacy Policy"]) {
        return ParrotIconPolicy; // Gray - Privacy policy
    } else if ([title isEqualToString:@"Terms Of Service"]) {
        return ParrotIconPolicy; // Gray - Terms of service
    } else if ([title isEqualToString:@"Sign Out"]) {
        return ParrotIconSignOut; // Orange - Sign out
    } else if ([title isEqualToString:@"Delete Account"]) {
        return ParrotIconDelete; // Red - Delete account
    } else {
        return ParrotIconDefault; // Default dark gray
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
