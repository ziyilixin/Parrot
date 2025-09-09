//
//  AppDelegate.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "AppDelegate.h"
#import "LaunchViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[LaunchViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
