//
//  MineHeadView.m
//  Parrot
//
//  Created by WCF on 2025/9/8.
//

#import "MineHeadView.h"

@implementation MineHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *photoImageView = [[UIImageView alloc] init];
        photoImageView.image = ImageNamed(@"login_logo");
        photoImageView.layer.masksToBounds = YES;
        photoImageView.layer.cornerRadius = 20;
        [self addSubview:photoImageView];
        [photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kStatusBarHeight + 20);
            make.centerX.equalTo(self);
            make.width.height.mas_equalTo(100);
        }];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = AppName;
        nameLabel.textColor = ParrotTextDarkGray; // Dark gray, consistent with new design
        nameLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold]; // Bold
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(photoImageView.mas_bottom).offset(8);
            make.centerX.equalTo(self);
        }];
        
        UILabel *versionLabel = [[UILabel alloc] init];
        versionLabel.text = [NSString stringWithFormat:@"Version %@",AppVersion];
        versionLabel.textColor = ParrotTextMediumGray; // Medium gray, suitable for new light background
        versionLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        [self addSubview:versionLabel];
        [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nameLabel.mas_bottom).offset(8);
            make.centerX.equalTo(self);
        }];
        
    }
    return self;
}

@end
