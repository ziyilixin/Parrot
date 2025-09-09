//
//  MineCell.h
//  Photography
//
//  Created by WCF on 2025/9/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, strong) UILabel *coinLabel;
@property (nonatomic, strong) UIView *lineView;
@end

NS_ASSUME_NONNULL_END
