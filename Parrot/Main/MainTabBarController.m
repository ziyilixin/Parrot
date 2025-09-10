//
//  MainTabBarController.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "MainTabBarController.h"
#import "HomeViewController.h"
#import "MineViewController.h"
#import "FAQViewController.h"
#import "MainNavigationController.h"

@interface MainTabBarController ()<UITabBarControllerDelegate>

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    [UITabBar appearance].translucent = NO;
    
    UITabBarAppearance *tabbarAppearance = [UITabBarAppearance new];
    [tabbarAppearance configureWithDefaultBackground];
    tabbarAppearance.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1.0];
    tabbarAppearance.shadowColor = [UIColor clearColor];
    tabbarAppearance.backgroundImage = [UIImage new];
    
    UITabBarItemAppearance *itemAppearance = [[UITabBarItemAppearance alloc] init];
    // Set TabBar text font style (used when text display is needed)
    itemAppearance.normal.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:PingFangBold size:12.0], NSForegroundColorAttributeName: ParrotTabNormalGray};
    itemAppearance.selected.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:PingFangBold size:12.0], NSForegroundColorAttributeName: ParrotPrimaryGreen};
    tabbarAppearance.stackedLayoutAppearance = itemAppearance;
    
    UITabBar.appearance.standardAppearance = tabbarAppearance;
    UITabBar.appearance.scrollEdgeAppearance = tabbarAppearance;
    
    [self addChildVC];
}

- (void)addChildVC {
    // Define icon colors
    UIColor *normalColor = ParrotTabNormalGray;  // Default gray
    UIColor *selectedColor = ParrotPrimaryGreen; // Green (represents nature, vitality)
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    // Home uses house icon, fits parrot care theme
    UIImage *homeNormalImage = [UIImage systemImageNamed:@"house"];
    UIImage *homeSelectedImage = [UIImage systemImageNamed:@"house.fill"];
    homeNormalImage = [homeNormalImage imageWithTintColor:normalColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    homeSelectedImage = [homeSelectedImage imageWithTintColor:selectedColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    homeVC.tabBarItem.image = homeNormalImage;
    homeVC.tabBarItem.selectedImage = homeSelectedImage;
    homeVC.tabBarItem.title = @"";
    // Move image down 6 pixels
    homeVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    MainNavigationController *homeNav = [[MainNavigationController alloc] initWithRootViewController:homeVC];
    
    // FAQ View Controller
    FAQViewController *faqVC = [[FAQViewController alloc] init];
    // FAQ uses question mark icon
    UIImage *faqNormalImage = [UIImage systemImageNamed:@"questionmark.circle"];
    UIImage *faqSelectedImage = [UIImage systemImageNamed:@"questionmark.circle.fill"];
    faqNormalImage = [faqNormalImage imageWithTintColor:normalColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    faqSelectedImage = [faqSelectedImage imageWithTintColor:selectedColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    faqVC.tabBarItem.image = faqNormalImage;
    faqVC.tabBarItem.selectedImage = faqSelectedImage;
    faqVC.tabBarItem.title = @"";
    // Move image down 6 pixels
    faqVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    MainNavigationController *faqNav = [[MainNavigationController alloc] initWithRootViewController:faqVC];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    // Mine uses person icon
    UIImage *mineNormalImage = [UIImage systemImageNamed:@"person"];
    UIImage *mineSelectedImage = [UIImage systemImageNamed:@"person.fill"];
    mineNormalImage = [mineNormalImage imageWithTintColor:normalColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    mineSelectedImage = [mineSelectedImage imageWithTintColor:selectedColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    mineVC.tabBarItem.image = mineNormalImage;
    mineVC.tabBarItem.selectedImage = mineSelectedImage;
    mineVC.tabBarItem.title = @"";
    // Move image down 6 pixels
    mineVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    MainNavigationController *mineNav = [[MainNavigationController alloc] initWithRootViewController:mineVC];
    
    [self setViewControllers:@[homeNav, faqNav, mineNav]];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [UIView setAnimationsEnabled:NO];
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [UIView setAnimationsEnabled:YES];
}
@end
