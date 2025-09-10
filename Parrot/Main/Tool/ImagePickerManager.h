//
//  ImagePickerManager.h
//  Kovela
//
//  Created by WCF on 2025/9/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ImagePickerManagerDelegate <NSObject>
@optional
/**
 * 图片选择完成的回调
 * @param picker 图片选择器
 * @param info 选择的图片信息
 */
- (void)ImagePickerManager:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;

/**
 * 取消选择图片的回调
 * @param picker 图片选择器
 */
- (void)ImagePickerManagerDidCancel:(UIImagePickerController *)picker;
@end

@interface ImagePickerManager : NSObject
/**
 * 代理对象
 */
@property (nonatomic, weak) id<ImagePickerManagerDelegate> delegate;

/**
 * 用于展示选择器的视图控制器
 */
@property (nonatomic, weak) UIViewController *presentingViewController;

/**
 * 获取单例实例
 * @return ImagePickerManager单例
 */
+ (instancetype)sharedInstance;

/**
 * 显示选择图片的选项（相机/相册）
 * @param viewController 用于展示选择器的视图控制器
 * @param type 用于标识是左侧还是右侧图片（0: 左侧, 1: 右侧）
 */
- (void)showImagePickerOptionsWithViewController:(UIViewController *)viewController;

/**
 * 打开相机
 */
- (void)openCamera;

/**
 * 打开相册
 */
- (void)openAlbum;
@end

NS_ASSUME_NONNULL_END
