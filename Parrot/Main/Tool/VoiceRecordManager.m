//
//  VoiceRecordManager.m
//  Kovela
//
//  Created by WCF on 2025/9/1.
//

#import "VoiceRecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>
#import "SpeechToText.h"
#import "ChatRecordHUD.h"

@interface VoiceRecordManager ()<AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSURL *audioFileURL;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) NSInteger recordDuration;

@property (nonatomic, strong) ChatRecordHUD *recordHUD;
@end

@implementation VoiceRecordManager
+ (instancetype)sharedInstance {
    static VoiceRecordManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VoiceRecordManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupAudioSession];
    }
    return self;
}

- (void)setupAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setActive:YES error:&error];
    
    // 设置录音文件路径
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *audioPath = [documentsPath stringByAppendingPathComponent:@"recording.m4a"];
    self.audioFileURL = [NSURL fileURLWithPath:audioPath];
}

- (void)startRecordingWithView:(UIView *)view {
    // 再次确认两个权限都已获取
    if ([SFSpeechRecognizer authorizationStatus] == SFSpeechRecognizerAuthorizationStatusAuthorized &&
        [[AVAudioSession sharedInstance] recordPermission] == AVAudioSessionRecordPermissionGranted) {
        
        if (!self.recordHUD) {
            self.recordHUD = [[ChatRecordHUD alloc] init];
        }
        __weak typeof(self) weakSelf = self;
        [self.recordHUD setOnTapEnd:^{
            [weakSelf stopRecording];
            [weakSelf.recordHUD dismiss];
        }];
        [self.recordHUD showInView:view.window ?: view];
        [self startRecording];
        self.recordDuration = 0;
        self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRecordDuration) userInfo:nil repeats:YES];
        
    }
}

- (void)startRecording {
    // 配置录音设置
    NSDictionary *settings = @{
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVSampleRateKey: @44100.0,
        AVNumberOfChannelsKey: @1,
        AVEncoderAudioQualityKey: @(AVAudioQualityHigh)
    };
    
    NSError *error;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileURL settings:settings error:&error];
    self.audioRecorder.delegate = self;
    
    if ([self.audioRecorder record]) {
        NSLog(@"开始录音");
    } else {
        NSLog(@"录音失败");
        if ([self.delegate respondsToSelector:@selector(VoiceRecordManagerDidFailRecording)]) {
            [self.delegate VoiceRecordManagerDidFailRecording];
        }
    }
}

- (void)stopRecording {
    if (self.audioRecorder.isRecording) {
        [self.audioRecorder stop];
        [self.recordTimer invalidate];
        self.recordTimer = nil;
        
        // 确保录音文件已经保存
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioFileURL.path]) {
            // 先停止所有正在进行的语音识别任务
            [[SpeechToText sharedInstance] cancelAllRecognitionTasks];
            
            // 延迟一小段时间再开始新的识别，确保之前的任务已经完全停止
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[SpeechToText sharedInstance] startRecognitionWithAudioURL:self.audioFileURL completion:^(NSString * _Nullable text, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (text.length > 0 && [self.delegate respondsToSelector:@selector(VoiceRecordManagerDidFinishRecordingWithText:)]) {
                            [self.delegate VoiceRecordManagerDidFinishRecordingWithText:text];
                        }
                    });
                }];
            });
        }
    }
}

- (void)checkMicrophonePermission:(void(^)(BOOL granted))completion {
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    
    if (permissionStatus == AVAudioSessionRecordPermissionUndetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(granted);
            });
        }];
    } else if (permissionStatus == AVAudioSessionRecordPermissionGranted) {
        completion(YES);
    } else {
        completion(NO);
    }
}

- (void)checkSpeechRecognitionPermission:(void(^)(BOOL granted))completion {
    if ([SFSpeechRecognizer authorizationStatus] == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        [[SpeechToText sharedInstance] requestAuthorization:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(granted);
            });
        }];
    } else if ([SFSpeechRecognizer authorizationStatus] == SFSpeechRecognizerAuthorizationStatusAuthorized) {
        completion(YES);
    } else {
        completion(NO);
    }
}

- (void)showPermissionAlertWithMessage:(NSString *)message viewController:(UIViewController *)viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hint"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Set up"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                        options:@{}
                              completionHandler:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)updateRecordDuration {
    self.recordDuration += 1;
    // 更新ChatRecordHUD显示
    [self.recordHUD updateDuration:self.recordDuration];
    
    // 可选：如需在弹窗上显示录音时长，可在VoiceRecordPopupView中实现updateDuration方法
    if ([self.delegate respondsToSelector:@selector(VoiceRecordManagerDidUpdateDuration:)]) {
        [self.delegate VoiceRecordManagerDidUpdateDuration:self.recordDuration];
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (!flag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"录音失败");
            if ([self.delegate respondsToSelector:@selector(VoiceRecordManagerDidFailRecording)]) {
                [self.delegate VoiceRecordManagerDidFailRecording];
            }
        });
    } else {
        NSLog(@"录音完成");
    }
}

@end
