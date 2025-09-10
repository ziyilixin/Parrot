//
//  AddParrotViewController.h
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import <UIKit/UIKit.h>
#import "ParrotDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddParrotViewController : UIViewController

@property (nonatomic, strong) ParrotInfo *parrotInfoToEdit; // 要编辑的鹦鹉信息，nil表示添加模式

@end

NS_ASSUME_NONNULL_END
