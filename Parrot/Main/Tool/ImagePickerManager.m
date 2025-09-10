//
//  ImagePickerManager.m
//  Kovela
//
//  Created by WCF on 2025/9/1.
//

#import "ImagePickerManager.h"
#import <Photos/Photos.h>

@interface ImagePickerManager ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@end

@implementation ImagePickerManager
+ (instancetype)sharedInstance {
    static ImagePickerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ImagePickerManager alloc] init];
    });
    return instance;
}

- (void)showImagePickerOptionsWithViewController:(UIViewController *)viewController {
    [viewController.view endEditing:YES];
    
    self.presentingViewController = viewController;
    self.delegate = (id<ImagePickerManagerDelegate>)viewController;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take photos"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"Select from the album"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [self openAlbum];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)openCamera {
    [self checkCameraPermission:^(BOOL granted) {
        if (granted) {
            [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"CameraPermissionDenied"];
            [NSUserDefaults.standardUserDefaults synchronize];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.delegate = self;
                self.imagePickerController = picker;
                [self.presentingViewController presentViewController:picker animated:YES completion:nil];
            } else {
                [self showAlertWithMessage:@"Camera is not available"];
            }
        } else {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            BOOL hasPermissionDenied = [NSUserDefaults.standardUserDefaults boolForKey:@"CameraPermissionDenied"];
            
            if (status == AVAuthorizationStatusDenied && hasPermissionDenied) {
                [self showPermissionAlert:@"Please allow camera access in Settings"];
            }
            
            [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"CameraPermissionDenied"];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
    }];
}

- (void)checkCameraPermission:(void(^)(BOOL granted))completion {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(granted);
            });
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        completion(YES);
    } else {
        completion(NO);
    }
}

- (void)openAlbum {
    [self checkPhotoLibraryPermission:^(BOOL granted) {
        if (granted) {
            [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"PhotoLibraryPermissionDenied"];
            [NSUserDefaults.standardUserDefaults synchronize];
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            self.imagePickerController = picker;
            [self.presentingViewController presentViewController:picker animated:YES completion:nil];
        } else {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            BOOL hasPermissionDenied = [NSUserDefaults.standardUserDefaults boolForKey:@"PhotoLibraryPermissionDenied"];
            
            if (status == PHAuthorizationStatusDenied && hasPermissionDenied) {
                [self showPermissionAlert:@"Please allow photo library access in Settings"];
            }
            
            [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"PhotoLibraryPermissionDenied"];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
    }];
}

- (void)checkPhotoLibraryPermission:(void(^)(BOOL granted))completion {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    completion(YES);
                } else {
                    completion(NO);
                }
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        completion(YES);
    } else {
        completion(NO);
    }
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hint"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Sure"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alert addAction:okAction];
    [self.presentingViewController presentViewController:alert animated:YES completion:nil];
}

- (void)showPermissionAlert:(NSString *)message {
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
    [self.presentingViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if ([self.delegate respondsToSelector:@selector(ImagePickerManager:didFinishPickingMediaWithInfo:)]) {
        [self.delegate ImagePickerManager:picker didFinishPickingMediaWithInfo:info];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([self.delegate respondsToSelector:@selector(ImagePickerManagerDidCancel:)]) {
        [self.delegate ImagePickerManagerDidCancel:picker];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
