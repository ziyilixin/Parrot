//
//  HomeViewController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "HomeViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // 延迟请求广告追踪权限，给用户一个更好的体验
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self applyAdvertising];
    });
}

- (void)applyAdvertising {
    if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    NSLog(@"用户尚未做出选择");
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    NSLog(@"访问受限");
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                    NSLog(@"用户拒绝了授权");
                    break;
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    NSLog(@"用户授权成功，可以使用IDFA: %@", [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
                    break;
            }
        }];
    } else {
        NSString *idfaString = @"";
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            NSUUID *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier];
            idfaString = [idfa UUIDString];
            NSLog(@"用户允许追踪，IDFA: %@", idfaString);
        } else {
            NSLog(@"用户关闭了广告追踪");
        }

    }
}

@end
