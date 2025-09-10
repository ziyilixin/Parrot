#import "AppleSignInManager.h"

@interface AppleSignInManager () <ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>

/**
 * 登录结果回调
 */
@property (nonatomic, copy) AppleSignInCompletion signInCompletion;

@end

@implementation AppleSignInManager

#pragma mark - Life Cycle

/**
 * 获取单例实例
 * 使用 dispatch_once 确保线程安全
 */
+ (instancetype)sharedInstance {
    static AppleSignInManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AppleSignInManager alloc] init];
    });
    return instance;
}

#pragma mark - Public Methods

/**
 * 检查设备是否支持苹果登录
 * 需要 iOS 13.0 及以上版本
 */
- (BOOL)isAppleSignInSupported {
    if (@available(iOS 13.0, *)) {
        return YES;
    }
    return NO;
}

/**
 * 处理苹果登录
 * 创建并展示苹果登录授权控制器
 */
- (void)handleAppleSignInWithCompletion:(AppleSignInCompletion)completion {
    if (![self isAppleSignInSupported]) {
        if (completion) {
            completion(AppleSignInStateNotSupport, nil, nil, nil, nil);
        }
        return;
    }
    
    self.signInCompletion = completion;
    
    // 创建苹果登录请求
    ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [provider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    
    // 创建授权控制器
    ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    controller.delegate = self;
    controller.presentationContextProvider = self;
    [controller performRequests];
}

/**
 * 处理苹果登录的回调URL
 * 用于处理从系统设置返回的回调
 */
- (BOOL)handleOpenURL:(NSURL *)url {
    if ([url.scheme isEqualToString:@"appleid"]) {
        // 处理苹果登录回调
        return YES;
    }
    return NO;
}

#pragma mark - ASAuthorizationControllerDelegate

/**
 * 授权成功回调
 */
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 获取用户信息
        ASAuthorizationAppleIDCredential *credential = (ASAuthorizationAppleIDCredential *)authorization.credential;
        NSString *state = credential.state;
        NSString *userID = credential.user;
        NSPersonNameComponents *nameComponents = credential.fullName;
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", nameComponents.givenName ?: @"", nameComponents.familyName ?: @""];
        NSString *email = credential.email;
        NSString *authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding];
        NSString *identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding];
        ASUserDetectionStatus realUserStatus = credential.realUserStatus;
        NSArray *authorizedScopes = credential.authorizedScopes;
        
        NSLog(@"state: %@", state);
        NSLog(@"userID: %@", userID);
        NSLog(@"fullName: %@", fullName);
        NSLog(@"email: %@", email);
        NSLog(@"authorizationCode: %@", authorizationCode);
        NSLog(@"identityToken: %@", identityToken);
        NSLog(@"realUserStatus: %@", @(realUserStatus));
        NSLog(@"authorizedScopes: %@", authorizedScopes);
        NSLog(@"identityToken = %@",identityToken);
        
        if (self.signInCompletion) {
            self.signInCompletion(AppleSignInStateSuccess, identityToken, email, fullName, nil);
        }
    }
}

/**
 * 授权失败回调
 */
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    if (self.signInCompletion) {
        if (error.code == ASAuthorizationErrorCanceled) {
            self.signInCompletion(AppleSignInStateCancelled, nil, nil, nil, error);
        } else {
            self.signInCompletion(AppleSignInStateFailed, nil, nil, nil, error);
        }
    }
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding

/**
 * 提供展示上下文
 */
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)) {
    return [UIApplication sharedApplication].windows.firstObject;
}

@end 
