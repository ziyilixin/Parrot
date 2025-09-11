//
//  FreeUsageManager.m
//  Parrot
//
//  Created by AI Assistant on 2025/09/10.
//

#import "FreeUsageManager.h"
#import "FMDB.h"

@interface FreeUsageManager ()
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *databasePath;
@end

@implementation FreeUsageManager

+ (instancetype)sharedManager {
    static FreeUsageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FreeUsageManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupDatabasePath];
        [self initializeDatabase];
    }
    return self;
}

- (void)setupDatabasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.databasePath = [documentsDirectory stringByAppendingPathComponent:@"free_usage.db"];
}

- (void)initializeDatabase {
    self.database = [FMDatabase databaseWithPath:self.databasePath];
    
    if ([self.database open]) {
        NSString *createTableSQL = @"CREATE TABLE IF NOT EXISTS free_usage ("
                                  @"id INTEGER PRIMARY KEY AUTOINCREMENT, "
                                  @"user_id TEXT NOT NULL UNIQUE, "
                                  @"remaining_count INTEGER NOT NULL DEFAULT 3, "
                                  @"created_at DATETIME DEFAULT CURRENT_TIMESTAMP, "
                                  @"updated_at DATETIME DEFAULT CURRENT_TIMESTAMP"
                                  @")";
        
        if ([self.database executeUpdate:createTableSQL]) {
            NSLog(@"Free usage table created successfully");
        } else {
            NSLog(@"Failed to create free usage table: %@", [self.database lastErrorMessage]);
        }
    } else {
        NSLog(@"Failed to open free usage database: %@", [self.database lastErrorMessage]);
    }
}

- (NSInteger)getRemainingFreeUsageForUser:(NSString *)userId {
    if (!userId || userId.length == 0) {
        return 0;
    }
    
    NSString *selectSQL = @"SELECT remaining_count FROM free_usage WHERE user_id = ?";
    FMResultSet *resultSet = [self.database executeQuery:selectSQL, userId];
    
    if ([resultSet next]) {
        NSInteger remainingCount = [resultSet intForColumn:@"remaining_count"];
        [resultSet close];
        return remainingCount;
    } else {
        // 如果用户不存在，创建新记录，默认3次免费机会
        NSString *insertSQL = @"INSERT INTO free_usage (user_id, remaining_count) VALUES (?, 3)";
        if ([self.database executeUpdate:insertSQL, userId]) {
            NSLog(@"Created new free usage record for user: %@", userId);
            return 3;
        } else {
            NSLog(@"Failed to create free usage record: %@", [self.database lastErrorMessage]);
            return 0;
        }
    }
}

- (BOOL)useFreeUsageForUser:(NSString *)userId {
    if (!userId || userId.length == 0) {
        return NO;
    }
    
    NSInteger remainingCount = [self getRemainingFreeUsageForUser:userId];
    if (remainingCount <= 0) {
        return NO;
    }
    
    NSString *updateSQL = @"UPDATE free_usage SET remaining_count = remaining_count - 1, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
    BOOL success = [self.database executeUpdate:updateSQL, userId];
    
    if (success) {
        NSLog(@"Used free usage for user: %@, remaining: %ld", userId, (long)(remainingCount - 1));
    } else {
        NSLog(@"Failed to use free usage: %@", [self.database lastErrorMessage]);
    }
    
    return success;
}

- (void)resetFreeUsageForUser:(NSString *)userId {
    if (!userId || userId.length == 0) {
        return;
    }
    
    NSString *updateSQL = @"UPDATE free_usage SET remaining_count = 3, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
    if ([self.database executeUpdate:updateSQL, userId]) {
        NSLog(@"Reset free usage for user: %@", userId);
    } else {
        NSLog(@"Failed to reset free usage: %@", [self.database lastErrorMessage]);
    }
}

- (BOOL)deleteFreeUsageForUser:(NSString *)userId {
    if (!userId || userId.length == 0) {
        NSLog(@"Invalid user ID for deletion");
        return NO;
    }
    
    // 确保数据库连接正常
    if (!self.database || ![self.database goodConnection]) {
        [self initializeDatabase];
    }
    
    NSString *deleteSQL = @"DELETE FROM free_usage WHERE user_id = ?";
    
    BOOL success = [self.database executeUpdate:deleteSQL, userId];
    
    if (success) {
        NSInteger changes = [self.database changes];
        NSLog(@"Successfully deleted free usage record for user: %@", userId);
    } else {
        NSLog(@"Failed to delete free usage record for user %@: %@", userId, [self.database lastErrorMessage]);
    }
    
    return success;
}

@end
