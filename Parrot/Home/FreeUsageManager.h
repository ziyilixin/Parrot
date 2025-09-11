//
//  FreeUsageManager.h
//  Parrot
//
//  Created by AI Assistant on 2025/09/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FreeUsageManager : NSObject

+ (instancetype)sharedManager;

// 获取用户剩余免费次数
- (NSInteger)getRemainingFreeUsageForUser:(NSString *)userId;

// 使用一次免费机会
- (BOOL)useFreeUsageForUser:(NSString *)userId;

// 重置用户免费次数（用于测试或特殊需求）
- (void)resetFreeUsageForUser:(NSString *)userId;

// User data cleanup
- (BOOL)deleteFreeUsageForUser:(NSString *)userId; // 删除指定用户的免费次数记录

@end

NS_ASSUME_NONNULL_END
