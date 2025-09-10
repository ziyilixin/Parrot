//
//  SpeechToText.m
//  Kovela
//
//  Created by WCF on 2025/9/1.
//

#import "SpeechToText.h"

@interface SpeechToText ()<SFSpeechRecognizerDelegate>
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) SFSpeechURLRecognitionRequest *recognitionRequest;
@end

@implementation SpeechToText
+ (instancetype)sharedInstance {
    static SpeechToText *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SpeechToText alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化语音识别器，默认使用系统语言
        self.speechRecognizer = [[SFSpeechRecognizer alloc] init];
        self.speechRecognizer.delegate = self;
    }
    return self;
}

- (void)requestAuthorization:(void(^)(BOOL granted))completion {
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status == SFSpeechRecognizerAuthorizationStatusAuthorized);
        });
    }];
}

- (void)startRecognitionWithAudioURL:(NSURL *)audioURL completion:(SpeechToTextCompletion)completion {
    // 检查权限
    if ([SFSpeechRecognizer authorizationStatus] != SFSpeechRecognizerAuthorizationStatusAuthorized) {
        NSError *error = [NSError errorWithDomain:@"SpeechToText"
                                           code:403
                                       userInfo:@{NSLocalizedDescriptionKey: @"There is no voice recognition permission"}];
        completion(nil, error);
        return;
    }
    
    // 检查语音识别器是否可用
    if (!self.speechRecognizer.isAvailable) {
        NSError *error = [NSError errorWithDomain:@"SpeechToText"
                                           code:1101
                                       userInfo:@{NSLocalizedDescriptionKey: @"Speech recognition service is not available. Please check your network connection and try again."}];
        completion(nil, error);
        return;
    }
    
    // 先取消之前的任务
    [self cancelRecognition];
    
    // 创建识别请求
    self.recognitionRequest = [[SFSpeechURLRecognitionRequest alloc] initWithURL:audioURL];
    self.recognitionRequest.shouldReportPartialResults = NO; // 只报告最终结果，减少错误
    
    // 创建识别任务
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest
                                                                 resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            // 过滤掉常见的系统错误，避免重复显示
            if (error.code != 1101) {
                NSLog(@"Speech recognition error：%@", error.localizedDescription);
                [SVProgressHUD showInfo:[NSString stringWithFormat:@"Speech recognition error：%@",error.localizedDescription]];
            } else {
                NSLog(@"Speech recognition service temporarily unavailable (Code: %ld)", (long)error.code);
            }
            completion(nil, error);
            return;
        }
        
        if (result.isFinal) {
            NSString *text = result.bestTranscription.formattedString;
            NSLog(@"Speech recognition result：%@", text);
            completion(text, nil);
        }
    }];
}

- (void)cancelRecognition {
    [self.recognitionTask cancel];
    self.recognitionTask = nil;
    self.recognitionRequest = nil;
}

- (void)cancelAllRecognitionTasks {
    // 取消当前任务
    [self cancelRecognition];
    
    // 重置语音识别器
    self.speechRecognizer = [[SFSpeechRecognizer alloc] init];
    self.speechRecognizer.delegate = self;
}

#pragma mark - SFSpeechRecognizerDelegate

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"Changes in the availability of speech recognizers：%d", available);
}
@end
