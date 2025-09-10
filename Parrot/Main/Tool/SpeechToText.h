//
//  SpeechToText.h
//  Kovela
//
//  Created by WCF on 2025/9/1.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SpeechToTextCompletion)(NSString * _Nullable text, NSError * _Nullable error);

@interface SpeechToText : NSObject
+ (instancetype)sharedInstance;

/**
 * 检查语音识别权限
 * @param completion 完成回调，返回是否有权限
 */
- (void)requestAuthorization:(void(^)(BOOL granted))completion;

/**
 * 开始语音识别
 * @param audioURL 音频文件URL
 * @param completion 完成回调，返回识别结果
 */
- (void)startRecognitionWithAudioURL:(NSURL *)audioURL completion:(SpeechToTextCompletion)completion;

/**
 * 取消语音识别
 */
- (void)cancelRecognition;

/**
 * 取消所有正在进行的语音识别任务
 */
- (void)cancelAllRecognitionTasks;
@end

NS_ASSUME_NONNULL_END
