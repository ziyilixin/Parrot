//
//  ParrotDataManager.m
//  Parrot
//
//  Created by WCF on 2025/9/9.
//

#import "ParrotDataManager.h"

@implementation ParrotInfo

@end

@interface ParrotDataManager ()
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *databasePath;
@end

@implementation ParrotDataManager

+ (instancetype)sharedManager {
    static ParrotDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeDatabase];
    }
    return self;
}

- (BOOL)initializeDatabase {
    // 获取文档目录路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.databasePath = [documentsDirectory stringByAppendingPathComponent:@"ParrotData.db"];
    
    // 创建数据库
    self.database = [FMDatabase databaseWithPath:self.databasePath];
    
    if (![self.database open]) {
        NSLog(@"Failed to open database");
        return NO;
    }
    
    // 创建鹦鹉信息表
    NSString *createTableSQL = @"CREATE TABLE IF NOT EXISTS parrot_info ("
                              @"id INTEGER PRIMARY KEY AUTOINCREMENT, "
                              @"name TEXT NOT NULL, "
                              @"breed TEXT, "
                              @"color TEXT, "
                              @"photo_path TEXT, "
                              @"birth_date REAL, "
                              @"user_id TEXT NOT NULL, "
                              @"created_at REAL NOT NULL, "
                              @"updated_at REAL NOT NULL"
                              @")";
    
    BOOL success = [self.database executeUpdate:createTableSQL];
    if (!success) {
        NSLog(@"Failed to create parrot_info table: %@", [self.database lastErrorMessage]);
        return NO;
    }
    
    // 创建索引
    [self.database executeUpdate:@"CREATE INDEX IF NOT EXISTS idx_user_id ON parrot_info(user_id)"];
    
    NSLog(@"Database initialized successfully at path: %@", self.databasePath);
    return YES;
}

- (void)closeDatabase {
    if (self.database) {
        [self.database close];
        self.database = nil;
    }
}

- (BOOL)saveParrotInfo:(ParrotInfo *)parrotInfo {
    if (!parrotInfo || !parrotInfo.name || parrotInfo.name.length == 0) {
        NSLog(@"Invalid parrot info for saving");
        return NO;
    }
    
    // 设置用户ID和时间戳
    parrotInfo.userId = LFWebData.shared.userId ?: @"";
    parrotInfo.createdAt = [NSDate date];
    parrotInfo.updatedAt = [NSDate date];
    
    NSString *insertSQL = @"INSERT INTO parrot_info (name, breed, color, photo_path, birth_date, user_id, created_at, updated_at) "
                         @"VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    
    BOOL success = [self.database executeUpdate:insertSQL,
                   parrotInfo.name,
                   parrotInfo.breed ?: @"",
                   parrotInfo.color ?: @"",
                   parrotInfo.photoPath ?: @"",
                   @([parrotInfo.birthDate timeIntervalSince1970]),
                   parrotInfo.userId,
                   @([parrotInfo.createdAt timeIntervalSince1970]),
                   @([parrotInfo.updatedAt timeIntervalSince1970])];
    
    if (success) {
        parrotInfo.parrotId = [self.database lastInsertRowId];
        NSLog(@"Parrot info saved successfully with ID: %ld", (long)parrotInfo.parrotId);
    } else {
        NSLog(@"Failed to save parrot info: %@", [self.database lastErrorMessage]);
    }
    
    return success;
}

- (BOOL)updateParrotInfo:(ParrotInfo *)parrotInfo {
    if (!parrotInfo || parrotInfo.parrotId <= 0) {
        NSLog(@"Invalid parrot info for updating");
        return NO;
    }
    
    parrotInfo.updatedAt = [NSDate date];
    
    NSString *updateSQL = @"UPDATE parrot_info SET "
                         @"name = ?, breed = ?, color = ?, photo_path = ?, birth_date = ?, updated_at = ? "
                         @"WHERE id = ? AND user_id = ?";
    
    BOOL success = [self.database executeUpdate:updateSQL,
                   parrotInfo.name,
                   parrotInfo.breed ?: @"",
                   parrotInfo.color ?: @"",
                   parrotInfo.photoPath ?: @"",
                   @([parrotInfo.birthDate timeIntervalSince1970]),
                   @([parrotInfo.updatedAt timeIntervalSince1970]),
                   @(parrotInfo.parrotId),
                   LFWebData.shared.userId ?: @""];
    
    if (!success) {
        NSLog(@"Failed to update parrot info: %@", [self.database lastErrorMessage]);
    }
    
    return success;
}

- (BOOL)deleteParrotInfoWithId:(NSInteger)parrotId {
    if (parrotId <= 0) {
        NSLog(@"Invalid parrot ID for deletion");
        return NO;
    }
    
    NSString *deleteSQL = @"DELETE FROM parrot_info WHERE id = ? AND user_id = ?";
    
    BOOL success = [self.database executeUpdate:deleteSQL, @(parrotId), LFWebData.shared.userId ?: @""];
    
    if (!success) {
        NSLog(@"Failed to delete parrot info: %@", [self.database lastErrorMessage]);
    }
    
    return success;
}

- (ParrotInfo *)getParrotInfoWithId:(NSInteger)parrotId {
    if (parrotId <= 0) {
        return nil;
    }
    
    NSString *selectSQL = @"SELECT * FROM parrot_info WHERE id = ? AND user_id = ?";
    
    FMResultSet *resultSet = [self.database executeQuery:selectSQL, @(parrotId), LFWebData.shared.userId ?: @""];
    
    ParrotInfo *parrotInfo = nil;
    if ([resultSet next]) {
        parrotInfo = [self parrotInfoFromResultSet:resultSet];
    }
    
    [resultSet close];
    return parrotInfo;
}

- (NSArray<ParrotInfo *> *)getAllParrotInfoForCurrentUser {
    NSString *selectSQL = @"SELECT * FROM parrot_info WHERE user_id = ? ORDER BY created_at DESC";
    
    FMResultSet *resultSet = [self.database executeQuery:selectSQL, LFWebData.shared.userId ?: @""];
    
    NSMutableArray<ParrotInfo *> *parrotInfoArray = [NSMutableArray array];
    while ([resultSet next]) {
        ParrotInfo *parrotInfo = [self parrotInfoFromResultSet:resultSet];
        if (parrotInfo) {
            [parrotInfoArray addObject:parrotInfo];
        }
    }
    
    [resultSet close];
    return [parrotInfoArray copy];
}

- (ParrotInfo *)getCurrentUserMainParrot {
    NSString *selectSQL = @"SELECT * FROM parrot_info WHERE user_id = ? ORDER BY created_at ASC LIMIT 1";
    
    FMResultSet *resultSet = [self.database executeQuery:selectSQL, LFWebData.shared.userId ?: @""];
    
    ParrotInfo *parrotInfo = nil;
    if ([resultSet next]) {
        parrotInfo = [self parrotInfoFromResultSet:resultSet];
    }
    
    [resultSet close];
    return parrotInfo;
}

- (BOOL)hasParrotInfoForCurrentUser {
    NSString *countSQL = @"SELECT COUNT(*) FROM parrot_info WHERE user_id = ?";
    
    FMResultSet *resultSet = [self.database executeQuery:countSQL, LFWebData.shared.userId ?: @""];
    
    BOOL hasParrot = NO;
    if ([resultSet next]) {
        NSInteger count = [resultSet intForColumnIndex:0];
        hasParrot = (count > 0);
    }
    
    [resultSet close];
    return hasParrot;
}

#pragma mark - Helper Methods

- (ParrotInfo *)parrotInfoFromResultSet:(FMResultSet *)resultSet {
    ParrotInfo *parrotInfo = [[ParrotInfo alloc] init];
    
    parrotInfo.parrotId = [resultSet longLongIntForColumn:@"id"];
    parrotInfo.name = [resultSet stringForColumn:@"name"];
    parrotInfo.breed = [resultSet stringForColumn:@"breed"];
    parrotInfo.color = [resultSet stringForColumn:@"color"];
    parrotInfo.photoPath = [resultSet stringForColumn:@"photo_path"];
    parrotInfo.userId = [resultSet stringForColumn:@"user_id"];
    
    double birthDateTimestamp = [resultSet doubleForColumn:@"birth_date"];
    if (birthDateTimestamp > 0) {
        parrotInfo.birthDate = [NSDate dateWithTimeIntervalSince1970:birthDateTimestamp];
    }
    
    double createdAtTimestamp = [resultSet doubleForColumn:@"created_at"];
    if (createdAtTimestamp > 0) {
        parrotInfo.createdAt = [NSDate dateWithTimeIntervalSince1970:createdAtTimestamp];
    }
    
    double updatedAtTimestamp = [resultSet doubleForColumn:@"updated_at"];
    if (updatedAtTimestamp > 0) {
        parrotInfo.updatedAt = [NSDate dateWithTimeIntervalSince1970:updatedAtTimestamp];
    }
    
    return parrotInfo;
}

- (BOOL)deleteAllParrotInfoForUser:(NSString *)userId {
    if (!userId || userId.length == 0) {
        NSLog(@"Invalid user ID for deletion");
        return NO;
    }
    
    // 确保数据库连接正常
    if (!self.database || ![self.database goodConnection]) {
        [self initializeDatabase];
    }
    
    NSString *deleteSQL = @"DELETE FROM parrot_info WHERE user_id = ?";
    
    BOOL success = [self.database executeUpdate:deleteSQL, userId];
    
    if (success) {
        NSInteger changes = [self.database changes];
        NSLog(@"Successfully deleted %ld parrot records for user: %@", (long)changes, userId);
    } else {
        NSLog(@"Failed to delete parrot records for user %@: %@", userId, [self.database lastErrorMessage]);
    }
    
    return success;
}

- (void)dealloc {
    [self closeDatabase];
}

@end
