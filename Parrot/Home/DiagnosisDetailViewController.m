//
//  DiagnosisDetailViewController.m
//  Parrot
//
//  Created by AI Assistant on 2025/09/10.
//

#import "DiagnosisDetailViewController.h"
#import "DiagnosisRecord.h"
#import "Masonry.h"
#import "ParrotColor.h"

@interface DiagnosisDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation DiagnosisDetailViewController

- (instancetype)initWithDiagnosisRecord:(DiagnosisRecord *)record {
    if (self = [super init]) {
        self.record = record;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadDiagnosisData];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.95 blue:0.9 alpha:1.0];
    
    // 隐藏系统导航栏
    self.navigationController.navigationBarHidden = YES;
    
    // 自定义导航栏容器
    UIView *navBarContainer = [[UIView alloc] init];
    navBarContainer.backgroundColor = [UIColor colorWithRed:0.9 green:0.95 blue:0.9 alpha:1.0];
    [self.view addSubview:navBarContainer];
    [navBarContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(kStatusBarHeight + 44);
    }];
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backIcon = [UIImage systemImageNamed:@"chevron.left"];
    backIcon = [backIcon imageWithTintColor:ParrotTextDarkGray renderingMode:UIImageRenderingModeAlwaysOriginal];
    [backBtn setImage:backIcon forState:UIControlStateNormal];
    [backBtn setImage:backIcon forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [navBarContainer addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(navBarContainer).offset(16);
        make.bottom.equalTo(navBarContainer).offset(-10);
        make.width.height.mas_equalTo(34);
    }];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Diagnosis Details";
    titleLabel.textColor = ParrotTextDarkGray;
    titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    [navBarContainer addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(navBarContainer);
        make.centerY.equalTo(backBtn);
    }];
    
    // 主滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(navBarContainer.mas_bottom);
    }];
    
    // 内容视图
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
}

- (void)loadDiagnosisData {
    // 清除现有内容
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    // 日期卡片
    UIView *dateCard = [self createDateCard];
    [self.contentView addSubview:dateCard];
    [dateCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.right.equalTo(self.contentView).inset(16);
    }];
    
    // 症状卡片
    UIView *symptomsCard = [self createSymptomsCard];
    [self.contentView addSubview:symptomsCard];
    [symptomsCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dateCard.mas_bottom).offset(20);
        make.left.right.equalTo(self.contentView).inset(16);
    }];
    
    // 图片卡片（如果有图片）
    UIView *lastCard = symptomsCard;
    if (self.record.photoPath && self.record.photoPath.length > 0) {
        UIView *photoCard = [self createPhotoCard];
        [self.contentView addSubview:photoCard];
        [photoCard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(symptomsCard.mas_bottom).offset(20);
            make.left.right.equalTo(self.contentView).inset(16);
        }];
        lastCard = photoCard;
    }
    
    // 诊断结果卡片
    UIView *resultCard = [self createResultCard];
    [self.contentView addSubview:resultCard];
    [resultCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastCard.mas_bottom).offset(20);
        make.left.right.equalTo(self.contentView).inset(16);
        make.bottom.equalTo(self.contentView).offset(-20);
    }];
}

- (UIView *)createDateCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 12;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowOpacity = 0.1;
    card.layer.shadowRadius = 4;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Diagnosis Date";
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    titleLabel.textColor = ParrotTextGray;
    [card addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(card).offset(16);
        make.right.lessThanOrEqualTo(card).offset(-16);
    }];
    
    UILabel *dateLabel = [[UILabel alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd, yyyy HH:mm";
    dateLabel.text = [formatter stringFromDate:self.record.createdDate];
    dateLabel.font = [UIFont systemFontOfSize:16];
    dateLabel.textColor = ParrotMainColor;
    dateLabel.numberOfLines = 0;
    [card addSubview:dateLabel];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
        make.left.equalTo(card).offset(16);
        make.right.bottom.equalTo(card).offset(-16);
    }];
    
    return card;
}

- (UIView *)createSymptomsCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 12;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowOpacity = 0.1;
    card.layer.shadowRadius = 4;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Symptoms Description";
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    titleLabel.textColor = ParrotTextGray;
    [card addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(card).offset(16);
        make.right.lessThanOrEqualTo(card).offset(-16);
    }];
    
    UILabel *symptomsLabel = [[UILabel alloc] init];
    symptomsLabel.text = self.record.symptoms;
    symptomsLabel.font = [UIFont systemFontOfSize:16];
    symptomsLabel.textColor = [UIColor blackColor];
    symptomsLabel.numberOfLines = 0;
    [card addSubview:symptomsLabel];
    [symptomsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
        make.left.equalTo(card).offset(16);
        make.right.bottom.equalTo(card).offset(-16);
    }];
    
    return card;
}

- (UIView *)createPhotoCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 12;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowOpacity = 0.1;
    card.layer.shadowRadius = 4;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Photo";
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    titleLabel.textColor = ParrotTextGray;
    [card addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(card).offset(16);
        make.right.lessThanOrEqualTo(card).offset(-16);
    }];
    
    UIImageView *photoImageView = [[UIImageView alloc] init];
    photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    photoImageView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    photoImageView.layer.cornerRadius = 8;
    photoImageView.clipsToBounds = YES;
    
    // 加载图片
    UIImage *photo = [self loadImageFromDocuments:self.record.photoPath];
    if (photo) {
        photoImageView.image = photo;
    } else {
        photoImageView.image = [UIImage systemImageNamed:@"photo"];
        photoImageView.tintColor = ParrotTextGray;
    }
    
    [card addSubview:photoImageView];
    [photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
        make.left.right.equalTo(card).inset(16);
        make.height.mas_equalTo(200);
        make.bottom.equalTo(card).offset(-16);
    }];
    
    return card;
}

- (UIView *)createResultCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 12;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowOpacity = 0.1;
    card.layer.shadowRadius = 4;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"AI Diagnosis Result";
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    titleLabel.textColor = ParrotTextGray;
    [card addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(card).offset(16);
        make.right.lessThanOrEqualTo(card).offset(-16);
    }];
    
    UILabel *confidenceLabel = [[UILabel alloc] init];
    confidenceLabel.text = [NSString stringWithFormat:@"Confidence: %@", self.record.confidence];
    confidenceLabel.font = [UIFont systemFontOfSize:12];
    confidenceLabel.textColor = ParrotMainColor;
    [card addSubview:confidenceLabel];
    [confidenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.left.equalTo(card).offset(16);
        make.right.lessThanOrEqualTo(card).offset(-16);
    }];
    
    UILabel *resultLabel = [[UILabel alloc] init];
    resultLabel.text = self.record.aiDiagnosis;
    resultLabel.font = [UIFont systemFontOfSize:16];
    resultLabel.textColor = [UIColor blackColor];
    resultLabel.numberOfLines = 0;
    [card addSubview:resultLabel];
    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(confidenceLabel.mas_bottom).offset(8);
        make.left.equalTo(card).offset(16);
        make.right.bottom.equalTo(card).offset(-16);
    }];
    
    return card;
}

- (UIImage *)loadImageFromDocuments:(NSString *)fileName {
    if (!fileName || fileName.length == 0) {
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    return [UIImage imageWithContentsOfFile:filePath];
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
