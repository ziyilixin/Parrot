//
//  ParrotDataManager.h
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParrotInfo : NSObject

@property (nonatomic, assign) NSInteger parrotId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *breed;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *photoPath; // 存储照片路径
@property (nonatomic, strong) NSDate *birthDate;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@end

@interface ParrotDataManager : NSObject

+ (instancetype)sharedManager;

// Database operations
- (BOOL)initializeDatabase;
- (void)closeDatabase;

// Parrot CRUD operations
- (BOOL)saveParrotInfo:(ParrotInfo *)parrotInfo;
- (BOOL)updateParrotInfo:(ParrotInfo *)parrotInfo;
- (BOOL)deleteParrotInfoWithId:(NSInteger)parrotId;
- (ParrotInfo * _Nullable)getParrotInfoWithId:(NSInteger)parrotId;
- (NSArray<ParrotInfo *> *)getAllParrotInfoForCurrentUser;
- (ParrotInfo * _Nullable)getCurrentUserMainParrot; // 获取当前用户的主要鹦鹉信息
- (BOOL)hasParrotInfoForCurrentUser; // 检查当前用户是否有鹦鹉信息

// User data cleanup
- (BOOL)deleteAllParrotInfoForUser:(NSString *)userId; // 删除指定用户的所有鹦鹉信息

@end

NS_ASSUME_NONNULL_END
