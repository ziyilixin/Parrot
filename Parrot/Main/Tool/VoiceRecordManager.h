//
//  VoiceRecordManager.h
//  Kovela
//
//  Created by WCF on 2025/9/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol VoiceRecordManagerDelegate <NSObject>
@optional
/**
 * 录音完成的回调
 * @param text 转换后的文字
 */
- (void)VoiceRecordManagerDidFinishRecordingWithText:(NSString *)text;

/**
 * 录音失败的回调
 */
- (void)VoiceRecordManagerDidFailRecording;

/**
 * 录音时长更新的回调
 * @param duration 当前录音时长（秒）
 */
- (void)VoiceRecordManagerDidUpdateDuration:(NSInteger)duration;
@end

@interface VoiceRecordManager : NSObject
/**
 * 代理对象
 */
@property (nonatomic, weak) id<VoiceRecordManagerDelegate> delegate;

/**
 * 获取单例实例
 * @return VoiceRecordManager单例
 */
+ (instancetype)sharedInstance;

/**
 * 开始录音
 * @param view 显示录音HUD的视图
 */
- (void)startRecordingWithView:(UIView *)view;

/**
 * 停止录音
 */
- (void)stopRecording;

/**
 * 检查麦克风权限
 * @param completion 权限检查完成的回调
 */
- (void)checkMicrophonePermission:(void(^)(BOOL granted))completion;

/**
 * 检查语音识别权限
 * @param completion 权限检查完成的回调
 */
- (void)checkSpeechRecognitionPermission:(void(^)(BOOL granted))completion;

/**
 * 显示权限提示
 * @param message 提示信息
 * @param viewController 用于显示提示的视图控制器
 */
- (void)showPermissionAlertWithMessage:(NSString *)message viewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
