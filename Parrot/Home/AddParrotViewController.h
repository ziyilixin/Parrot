//
//  AddParrotViewController.h
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddParrotViewControllerDelegate <NSObject>
- (void)didAddParrotSuccessfully;
@end

@interface AddParrotViewController : UIViewController

@property (nonatomic, weak) id<AddParrotViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
