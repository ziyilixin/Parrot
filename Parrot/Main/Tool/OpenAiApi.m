//
//  OpenAiApi.m
//  Parrot
//
//  Created by WCF on 2025/9/1.
//

#import "OpenAiApi.h"
#import <AFNetworking/AFNetworking.h>

@implementation OpenAiApi
- (void)sendMessageToChatGPT:(NSString *)message
                   imagePath:(NSString *)imagePath
                  completion:(void (^)(NSString *reply, NSError *error))completion {
    
    // 构建系统提示
    NSString *systemPromptContent = [NSString stringWithFormat:@"A parrot breeding expert. \nYour expertise includes:\n1. Basic knowledge: Proficient in the classification of parrots, their native habits, physiological structure, and life cycle characteristics.\n2. Practical breeding: Skilled in designing cages, regulating the environment, providing scientific diets, conducting daily care (such as trimming feathers and trimming beaks), and managing during special periods (reproduction, chick rearing).\n3. Behavior and training: Capable of interpreting the emotional and behavioral signals of parrots, conducting skill training through positive guidance, correcting bad behaviors, and taking into account their social and emotional needs.\n4. Health management: Able to assess the health status of parrots through observation, master the prevention and treatment of common diseases and basic first aid, and be able to cooperate with veterinarians in treatment."];
    NSDictionary *systemPrompt = @{
        @"role": @"system",
        @"content": systemPromptContent
    };
    
    NSMutableArray<NSDictionary *> *messages = [NSMutableArray arrayWithObject:systemPrompt];
    
    if (imagePath != nil) {
        // 如果有图片，使用 Vision API
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        NSString *base64Image = [imageData base64EncodedStringWithOptions:0];
        
        NSString *textContent = message.length == 0 ? @"Please analyze this photo from the perspective of a parrot breeding expert and provide your professional opinion." : [NSString stringWithFormat:@"Please analyze this picture related to parrots and answer my questions: %@", message];
        NSDictionary *userMessage = @{
            @"role": @"user",
            @"content": @[
                @{
                    @"type": @"text",
                    @"text": textContent
                },
                @{
                    @"type": @"image_url",
                    @"image_url": @{
                        @"url": [NSString stringWithFormat:@"data:image/jpeg;base64,%@", base64Image]
                    }
                }
            ]
        };
        [messages addObject:userMessage];
    } else {
        // 纯文本消息
        NSDictionary *userMessage = @{
            @"role": @"user",
            @"content": message
        };
        [messages addObject:userMessage];
    }
    
    // 构建请求体
    NSDictionary *requestBody = @{
        //@"model": @"gpt-4o-mini",
        @"model": @"gpt-4o",
        @"messages": messages,
        //@"max_tokens": @1000,
        @"temperature": @0.7
    };
    
    // 配置 AFNetworking
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // 设置请求头
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *aiChatKey = @"sk-O9bParrot-l-XfNeMHnYOuLU4QParrot-l-un6MBztDsZWBXMParrot-l-4RS2CiZckxhK57OOU";
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@",[self rUrl:aiChatKey]];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    // 发送请求
    NSString *aiChatApiUrl = @"https://api.Parrot-l-chatanyParrot-l-whereParrot-l-.tech/";
    NSString *urlString = [NSString stringWithFormat:@"%@v1/chat/completions", [self rUrl:aiChatApiUrl]];
    [manager POST:urlString parameters:requestBody headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@",responseObject);
        NSString *reply = responseObject[@"choices"][0][@"message"][@"content"];
        completion(reply, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (NSString *)rUrl:(NSString *)url{
    return [url stringByReplacingOccurrencesOfString:@"Parrot-l-" withString:@""];
}

@end
