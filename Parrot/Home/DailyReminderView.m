//
//  DailyReminderView.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "DailyReminderView.h"

@interface DailyReminderView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSArray *defaultReminders;
@end

@implementation DailyReminderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupDefaultReminders];
        [self setupUI];
    }
    return self;
}

- (void)setupDefaultReminders {
    self.defaultReminders = @[
        @{@"title": @"Feeding", @"time": @"08:00", @"icon": @"fork.knife", @"color": @"orange"},
        @{@"title": @"Water Change", @"time": @"10:00", @"icon": @"drop", @"color": @"blue"},
        @{@"title": @"Cage Cleaning", @"time": @"18:00", @"icon": @"house", @"color": @"green"},
        @{@"title": @"Wing Clipping", @"time": @"Monthly", @"icon": @"scissors", @"color": @"purple"},
        @{@"title": @"Deworming", @"time": @"Quarterly", @"icon": @"shield", @"color": @"red"},
        @{@"title": @"Vaccination", @"time": @"Yearly", @"icon": @"syringe", @"color": @"teal"}
    ];
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    // Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Daily Reminders";
    titleLabel.textColor = ParrotTextDarkGray;
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(16);
        make.left.equalTo(self).offset(20);
    }];
    
    // Scroll view
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(12);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-16);
    }];
    
    // Stack view
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 12;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFillEqually;
    [scrollView addSubview:stackView];
    self.stackView = stackView;
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.height.equalTo(scrollView);
    }];
    
    [self createReminderCards];
}

- (void)createReminderCards {
    // Clear existing cards
    for (UIView *subview in self.stackView.arrangedSubviews) {
        [self.stackView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    
    for (NSDictionary *reminder in self.defaultReminders) {
        UIView *cardView = [self createReminderCardWithInfo:reminder];
        [self.stackView addArrangedSubview:cardView];
        [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(120);
        }];
    }
    
    // Add left and right margins
    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(16);
        make.right.equalTo(self.scrollView).offset(-16);
    }];
}

- (UIView *)createReminderCardWithInfo:(NSDictionary *)info {
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = ColorFFFFFF;
    cardView.layer.cornerRadius = 12;
    cardView.layer.masksToBounds = YES;
    
    // Add shadow effect
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOffset = CGSizeMake(0, 2);
    cardView.layer.shadowOpacity = 0.1;
    cardView.layer.shadowRadius = 6;
    cardView.layer.masksToBounds = NO;
    
    // Icon background view
    UIView *iconBgView = [[UIView alloc] init];
    iconBgView.layer.cornerRadius = 20;
    iconBgView.backgroundColor = [self getColorForType:info[@"color"]];
    [cardView addSubview:iconBgView];
    [iconBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cardView).offset(16);
        make.centerX.equalTo(cardView);
        make.width.height.mas_equalTo(40);
    }];
    
    // Icon
    UIImageView *iconView = [[UIImageView alloc] init];
    UIImage *icon = [UIImage systemImageNamed:info[@"icon"]];
    icon = [icon imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
    iconView.image = icon;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [iconBgView addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBgView);
        make.width.height.mas_equalTo(20);
    }];
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = info[@"title"];
    titleLabel.textColor = ParrotTextDarkGray;
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [cardView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconBgView.mas_bottom).offset(8);
        make.left.equalTo(cardView).offset(8);
        make.right.equalTo(cardView).offset(-8);
    }];
    
    // Time
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = info[@"time"];
    timeLabel.textColor = ParrotTextMediumGray;
    timeLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [cardView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.left.equalTo(cardView).offset(8);
        make.right.equalTo(cardView).offset(-8);
        make.bottom.equalTo(cardView).offset(-16);
    }];
    
    // Add tap gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reminderCardTapped:)];
    [cardView addGestureRecognizer:tapGesture];
    cardView.tag = [self.defaultReminders indexOfObject:info];
    
    return cardView;
}

- (UIColor *)getColorForType:(NSString *)colorType {
    if ([colorType isEqualToString:@"orange"]) {
        return [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
    } else if ([colorType isEqualToString:@"blue"]) {
        return [UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:1.0];
    } else if ([colorType isEqualToString:@"green"]) {
        return ParrotPrimaryGreen;
    } else if ([colorType isEqualToString:@"purple"]) {
        return [UIColor colorWithRed:0.6 green:0.4 blue:0.9 alpha:1.0];
    } else if ([colorType isEqualToString:@"red"]) {
        return [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
    } else if ([colorType isEqualToString:@"teal"]) {
        return [UIColor colorWithRed:0.0 green:0.7 blue:0.7 alpha:1.0];
    }
    return ParrotPrimaryGreen;
}

- (void)reminderCardTapped:(UITapGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag;
    NSDictionary *reminder = self.defaultReminders[index];
    NSLog(@"Tapped reminder card: %@", reminder[@"title"]);
    // TODO: Implement reminder setting functionality
}

- (void)updateReminders:(NSArray *)reminders {
    if (reminders && reminders.count > 0) {
        self.defaultReminders = reminders;
        [self createReminderCards];
    }
}

@end
