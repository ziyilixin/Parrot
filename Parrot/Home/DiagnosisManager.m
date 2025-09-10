//
//  DiagnosisManager.m
//  Parrot
//
//  Created by WCF on 2025/9/10.
//

#import "DiagnosisManager.h"
#import "FMDB.h"

@interface DiagnosisManager ()
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *databasePath;
@end

@implementation DiagnosisManager

+ (instancetype)sharedManager {
    static DiagnosisManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DiagnosisManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupDatabasePath];
    }
    return self;
}

- (void)setupDatabasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.databasePath = [documentsDirectory stringByAppendingPathComponent:@"diagnosis_records.db"];
}

- (void)initializeDatabase {
    self.database = [FMDatabase databaseWithPath:self.databasePath];
    
    if ([self.database open]) {
        NSString *createTableSQL = @"CREATE TABLE IF NOT EXISTS diagnosis_records ("
                                  @"id INTEGER PRIMARY KEY AUTOINCREMENT, "
                                  @"record_id TEXT NOT NULL, "
                                  @"user_id TEXT NOT NULL, "
                                  @"symptoms TEXT NOT NULL, "
                                  @"photo_path TEXT, "
                                  @"ai_diagnosis TEXT, "
                                  @"confidence TEXT, "
                                  @"created_date REAL NOT NULL, "
                                  @"updated_date REAL NOT NULL"
                                  @")";
        
        if ([self.database executeUpdate:createTableSQL]) {
            NSLog(@"Diagnosis records table created successfully");
        } else {
            NSLog(@"Failed to create diagnosis records table: %@", [self.database lastError]);
        }
    } else {
        NSLog(@"Failed to open diagnosis database: %@", [self.database lastError]);
    }
}

- (void)closeDatabase {
    if (self.database) {
        [self.database close];
        self.database = nil;
    }
}

- (BOOL)saveDiagnosisRecord:(DiagnosisRecord *)record {
    if (!self.database || ![self.database goodConnection]) {
        [self initializeDatabase];
    }
    
    NSString *sql = @"INSERT INTO diagnosis_records (record_id, user_id, symptoms, photo_path, ai_diagnosis, confidence, created_date, updated_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    
    BOOL success = [self.database executeUpdate:sql,
                   record.recordId,
                   record.userId,
                   record.symptoms,
                   record.photoPath ?: [NSNull null],
                   record.aiDiagnosis,
                   record.confidence,
                   @([record.createdDate timeIntervalSince1970]),
                   @([record.updatedDate timeIntervalSince1970])];
    
    if (!success) {
        NSLog(@"Failed to save diagnosis record: %@", [self.database lastError]);
    }
    
    return success;
}

- (BOOL)updateDiagnosisRecord:(DiagnosisRecord *)record {
    if (!self.database || ![self.database goodConnection]) {
        [self initializeDatabase];
    }
    
    NSString *sql = @"UPDATE diagnosis_records SET symptoms = ?, photo_path = ?, ai_diagnosis = ?, confidence = ?, updated_date = ? WHERE record_id = ?";
    
    BOOL success = [self.database executeUpdate:sql,
                   record.symptoms,
                   record.photoPath ?: [NSNull null],
                   record.aiDiagnosis,
                   record.confidence,
                   @([[NSDate date] timeIntervalSince1970]),
                   record.recordId];
    
    if (!success) {
        NSLog(@"Failed to update diagnosis record: %@", [self.database lastError]);
    }
    
    return success;
}

- (BOOL)deleteDiagnosisRecord:(NSString *)recordId {
    if (!self.database || ![self.database goodConnection]) {
        [self initializeDatabase];
    }
    
    NSString *sql = @"DELETE FROM diagnosis_records WHERE record_id = ?";
    BOOL success = [self.database executeUpdate:sql, recordId];
    
    if (!success) {
        NSLog(@"Failed to delete diagnosis record: %@", [self.database lastError]);
    }
    
    return success;
}

- (NSArray<DiagnosisRecord *> *)getAllDiagnosisRecords {
    if (!self.database || ![self.database goodConnection]) {
        [self initializeDatabase];
    }
    
    NSString *sql = @"SELECT * FROM diagnosis_records ORDER BY created_date DESC";
    FMResultSet *resultSet = [self.database executeQuery:sql];
    
    NSMutableArray *records = [NSMutableArray array];
    while ([resultSet next]) {
        DiagnosisRecord *record = [self diagnosisRecordFromResultSet:resultSet];
        [records addObject:record];
    }
    
    return [records copy];
}

- (NSArray<DiagnosisRecord *> *)getDiagnosisRecordsForUserId:(NSString *)userId {
    if (!self.database || ![self.database goodConnection]) {
        [self initializeDatabase];
    }
    
    NSString *sql = @"SELECT * FROM diagnosis_records WHERE user_id = ? ORDER BY created_date DESC";
    FMResultSet *resultSet = [self.database executeQuery:sql, userId];
    
    NSMutableArray *records = [NSMutableArray array];
    while ([resultSet next]) {
        DiagnosisRecord *record = [self diagnosisRecordFromResultSet:resultSet];
        [records addObject:record];
    }
    
    return [records copy];
}

- (DiagnosisRecord *)getDiagnosisRecordById:(NSString *)recordId {
    if (!self.database || ![self.database goodConnection]) {
        [self initializeDatabase];
    }
    
    NSString *sql = @"SELECT * FROM diagnosis_records WHERE record_id = ?";
    FMResultSet *resultSet = [self.database executeQuery:sql, recordId];
    
    if ([resultSet next]) {
        return [self diagnosisRecordFromResultSet:resultSet];
    }
    
    return nil;
}

- (DiagnosisRecord *)diagnosisRecordFromResultSet:(FMResultSet *)resultSet {
    DiagnosisRecord *record = [[DiagnosisRecord alloc] init];
    record.recordId = [resultSet stringForColumn:@"record_id"];
    record.userId = [resultSet stringForColumn:@"user_id"];
    record.symptoms = [resultSet stringForColumn:@"symptoms"];
    record.photoPath = [resultSet stringForColumn:@"photo_path"];
    record.aiDiagnosis = [resultSet stringForColumn:@"ai_diagnosis"];
    record.confidence = [resultSet stringForColumn:@"confidence"];
    record.createdDate = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumn:@"created_date"]];
    record.updatedDate = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumn:@"updated_date"]];
    return record;
}

#pragma mark - AI Diagnosis

- (void)performAIDiagnosisWithSymptoms:(NSString *)symptoms
                            photoPath:(NSString *)photoPath
                           completion:(void(^)(NSString *diagnosis, NSString *confidence, NSError *error))completion {
    
    // 模拟AI诊断过程
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 这里应该调用真实的AI API，现在使用模拟数据
        NSString *diagnosis = [self generateMockDiagnosis:symptoms];
        NSString *confidence = [self generateMockConfidence];
        
        if (completion) {
            completion(diagnosis, confidence, nil);
        }
    });
}

- (NSString *)generateMockDiagnosis:(NSString *)symptoms {
    NSArray *possibleDiagnoses = @[
        @"Based on the symptoms described, your parrot may be experiencing mild respiratory issues. It's recommended to monitor closely and ensure proper ventilation.",
        @"The symptoms suggest possible nutritional deficiency. Consider reviewing your parrot's diet and adding more fresh fruits and vegetables.",
        @"These symptoms could indicate stress or environmental changes. Ensure your parrot has a quiet, comfortable environment with adequate rest.",
        @"The described symptoms may be related to seasonal changes. Monitor your parrot's behavior and consult a veterinarian if symptoms persist.",
        @"Based on the information provided, your parrot appears to be in good health. Continue with regular care and monitoring."
    ];
    
    NSUInteger randomIndex = arc4random_uniform((uint32_t)possibleDiagnoses.count);
    return possibleDiagnoses[randomIndex];
}

- (NSString *)generateMockConfidence {
    NSArray *confidenceLevels = @[@"85%", @"78%", @"92%", @"67%", @"88%"];
    NSUInteger randomIndex = arc4random_uniform((uint32_t)confidenceLevels.count);
    return confidenceLevels[randomIndex];
}

@end
