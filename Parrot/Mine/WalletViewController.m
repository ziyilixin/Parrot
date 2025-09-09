//
//  WalletViewController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "WalletViewController.h"
#import "MineCoinCell.h"
#import "WalletHeadView.h"

@interface WalletViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) OrderInfoModel *orderEntity;
@property (nonatomic, strong) WalletHeadView *headView;
@end

static NSString * const coinCellId = @"MineCoinCell";
static NSString * const headViewId = @"WalletHeadView";

@implementation WalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeUI];
    
    [self loadGoods];
    
    [self getUserCoins];
    
    [[LFPurchaseManager shared] initAction];
}

- (void)initializeUI {
    // Create elegant gradient background
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    
    // Use soft green gradient, fits parrot care app's natural theme
    UIColor *topColor = ParrotBgGradientTop; // Light green
    UIColor *bottomColor = ParrotBgGradientBottom; // Lighter green-white
    
    gradientLayer.colors = @[(__bridge id)topColor.CGColor, (__bridge id)bottomColor.CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(0.0, 1.0);
    
    UIView *bgView = [[UIView alloc] init];
    [bgView.layer addSublayer:gradientLayer];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // Ensure gradient layer adjusts correctly when view size changes
    dispatch_async(dispatch_get_main_queue(), ^{
        gradientLayer.frame = self.view.bounds;
    });
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(16, kStatusBarHeight + 20, 34, 34);
    // Use system back icon with consistent color
    UIImage *backIcon = [UIImage systemImageNamed:@"chevron.left"];
    backIcon = [backIcon imageWithTintColor:ParrotTextDarkGray renderingMode:UIImageRenderingModeAlwaysOriginal];
    [backBtn setImage:backIcon forState:UIControlStateNormal];
    [backBtn setImage:backIcon forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Store";
    titleLabel.textColor = ParrotTextDarkGray;
    titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(backBtn);
    }];
    
    CGFloat coinH = (kScreenWidth - 38*2)*90/300;
    CGFloat headH = coinH + 20;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = (kScreenWidth - 20*2 - 15) / 2;
    CGFloat itemHeight = itemWidth * 171 / 160;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.headerReferenceSize = CGSizeMake(kScreenWidth, headH);
    layout.footerReferenceSize = CGSizeZero;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(backBtn.mas_bottom).offset(32);
        make.bottom.equalTo(self.view);
    }];
    
    [self.collectionView registerClass:[MineCoinCell class] forCellWithReuseIdentifier:coinCellId];
    [self.collectionView registerClass:[WalletHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewId];
}

- (void)loadGoods {
    [SVProgressHUD showLoading];
    [CoinReository coinGoodsSearchWithCompletion:^(NSArray<CoinGoodEntity *> *goods, BOOL isSuccess) {
        [SVProgressHUD dismiss];
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataArray = [goods mutableCopy];
                [self.collectionView reloadData];
            });
        }
    } completionHandler:^{
        [SVProgressHUD dismiss];
    }];
}

- (void)getUserCoins {
    [SVProgressHUD showLoading];
    [UserRepository getUserCoinsWithCompletion:^(NSInteger availableCoins, BOOL isSuccess) {
        [SVProgressHUD dismiss];
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.headView.coinNumLabel.text = [NSString stringWithFormat:@"%ld coins",(long)availableCoins];
            });
        }
    } completionHandler:^{
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MineCoinCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:coinCellId forIndexPath:indexPath];
    cell.good = self.dataArray[indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        WalletHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewId forIndexPath:indexPath];
        self.headView = headView;
        return headView;
    }
    else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CoinGoodEntity *good = self.dataArray[indexPath.item];
    [[LFPurchaseManager shared] buy:good.code paySource:@"" invitationId:@"" eventExtData:@{} broadcasterId:@"" scriptId:@"" routerPaths:@[] buyBlock:^(BOOL isSuccee) {
        if (isSuccee) {
            [SVProgressHUD showInfo:@"Buy Success"];
            [self getUserCoins];
        }
        else {
            NSLog(@"Buy Failure");
        }
    }];
}

- (void)backClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)dealloc {
    [[LFPurchaseManager shared] removePaymentObserver];
}


@end
