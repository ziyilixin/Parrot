//
//  DiagnosisHistoryViewController.m
//  Parrot
//
//  Created by AI Assistant on 2025/09/10.
//

#import "DiagnosisHistoryViewController.h"
#import "DiagnosisManager.h"
#import "DiagnosisRecord.h"
#import "DiagnosisDetailViewController.h"
#import "Masonry.h"
#import "ParrotColor.h"

@interface DiagnosisHistoryViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray<DiagnosisRecord *> *diagnosisRecords;
@property (nonatomic, strong) DiagnosisManager *diagnosisManager;

@end

@implementation DiagnosisHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadDiagnosisRecords];
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
    titleLabel.text = @"Diagnosis History";
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

- (void)loadDiagnosisRecords {
    self.diagnosisManager = [DiagnosisManager sharedManager];
    self.diagnosisRecords = [self.diagnosisManager getAllDiagnosisRecords];
    
    [self setupHistoryList];
}

- (void)setupHistoryList {
    // 清除现有内容
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (self.diagnosisRecords.count == 0) {
        // 显示空状态
        UILabel *emptyLabel = [[UILabel alloc] init];
        emptyLabel.text = @"No diagnosis records found";
        emptyLabel.textColor = ParrotTextGray;
        emptyLabel.font = [UIFont systemFontOfSize:16];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:emptyLabel];
        [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.scrollView).offset(100);
        }];
    } else {
        // 显示所有记录
        UIView *lastView = nil;
        for (NSInteger i = 0; i < self.diagnosisRecords.count; i++) {
            DiagnosisRecord *record = self.diagnosisRecords[i];
            UIView *recordView = [self createHistoryRecordView:record atIndex:i];
            [self.contentView addSubview:recordView];
            
            [recordView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView).inset(16);
                if (lastView) {
                    make.top.equalTo(lastView.mas_bottom).offset(16);
                } else {
                    make.top.equalTo(self.contentView).offset(20);
                }
            }];
            
            lastView = recordView;
        }
        
        // 设置内容视图的底部约束
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.scrollView).offset(-20);
        }];
    }
}

- (UIView *)createHistoryRecordView:(DiagnosisRecord *)record atIndex:(NSInteger)index {
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 12;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 2);
    containerView.layer.shadowOpacity = 0.1;
    containerView.layer.shadowRadius = 4;
    
    // 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordViewTapped:)];
    [containerView addGestureRecognizer:tapGesture];
    containerView.userInteractionEnabled = YES;
    containerView.tag = index; // 存储记录索引
    
    // Date label
    UILabel *dateLabel = [[UILabel alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd, yyyy HH:mm";
    dateLabel.text = [formatter stringFromDate:record.createdDate];
    dateLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    dateLabel.textColor = ParrotMainColor;
    [containerView addSubview:dateLabel];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(containerView).offset(16);
        make.right.lessThanOrEqualTo(containerView).offset(-40);
    }];
    
    // Symptoms label
    UILabel *symptomsLabel = [[UILabel alloc] init];
    symptomsLabel.text = record.symptoms;
    symptomsLabel.font = [UIFont systemFontOfSize:16];
    symptomsLabel.textColor = [UIColor blackColor];
    symptomsLabel.numberOfLines = 2;
    [containerView addSubview:symptomsLabel];
    [symptomsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dateLabel.mas_bottom).offset(8);
        make.left.equalTo(containerView).offset(16);
        make.right.equalTo(containerView).offset(-40);
    }];
    
    // Diagnosis result label
    UILabel *diagnosisLabel = [[UILabel alloc] init];
    diagnosisLabel.text = record.aiDiagnosis;
    diagnosisLabel.font = [UIFont systemFontOfSize:14];
    diagnosisLabel.textColor = ParrotTextGray;
    diagnosisLabel.numberOfLines = 2;
    [containerView addSubview:diagnosisLabel];
    [diagnosisLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(symptomsLabel.mas_bottom).offset(8);
        make.left.equalTo(containerView).offset(16);
        make.right.equalTo(containerView).offset(-40);
        make.bottom.equalTo(containerView).offset(-16);
    }];
    
    // 箭头指示器
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.image = [UIImage systemImageNamed:@"chevron.right"];
    arrowImageView.tintColor = ParrotTextGray;
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    [containerView addSubview:arrowImageView];
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView);
        make.right.equalTo(containerView).offset(-16);
        make.width.height.mas_equalTo(16);
    }];
    
    return containerView;
}

- (void)recordViewTapped:(UITapGestureRecognizer *)gesture {
    UIView *tappedView = gesture.view;
    NSInteger recordIndex = tappedView.tag;
    
    if (recordIndex >= 0 && recordIndex < self.diagnosisRecords.count) {
        DiagnosisRecord *selectedRecord = self.diagnosisRecords[recordIndex];
        
        // 跳转到诊断详情页面
        DiagnosisDetailViewController *detailVC = [[DiagnosisDetailViewController alloc] initWithDiagnosisRecord:selectedRecord];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
