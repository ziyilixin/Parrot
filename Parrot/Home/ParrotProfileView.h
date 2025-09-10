//
//  ParrotProfileView.h
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParrotProfileView : UIView

@property (nonatomic, strong) NSString *parrotName;
@property (nonatomic, strong) NSString *breed;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) UIImage *parrotPhoto;
@property (nonatomic, strong) NSDate *birthDate;

- (void)updateParrotInfo:(NSDictionary *)parrotInfo;
- (void)loadParrotData;

@end

NS_ASSUME_NONNULL_END
