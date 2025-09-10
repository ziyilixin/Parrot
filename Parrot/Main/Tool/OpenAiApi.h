//
//  OpenAiApi.h
//  Parrot
//
//  Created by WCF on 2025/9/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenAiApi : NSObject
- (void)sendMessageToChatGPT:(NSString *)message
                   imagePath:(NSString *)imagePath
                  completion:(void (^)(NSString *reply, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
