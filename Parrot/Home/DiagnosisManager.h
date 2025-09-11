//
//  DiagnosisManager.h
//  Parrot
//
//  Created by WCF on 2025/9/10.
//

#import <Foundation/Foundation.h>
#import "DiagnosisRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface DiagnosisManager : NSObject

+ (instancetype)sharedManager;

// 数据库操作
- (void)initializeDatabase;
- (void)closeDatabase;

// 诊断记录操作
- (BOOL)saveDiagnosisRecord:(DiagnosisRecord *)record;
- (BOOL)updateDiagnosisRecord:(DiagnosisRecord *)record;
- (BOOL)deleteDiagnosisRecord:(NSString *)recordId;
- (NSArray<DiagnosisRecord *> *)getAllDiagnosisRecords;
- (NSArray<DiagnosisRecord *> *)getDiagnosisRecordsForUserId:(NSString *)userId;
- (DiagnosisRecord *)getDiagnosisRecordById:(NSString *)recordId;

// User data cleanup
- (BOOL)deleteAllDiagnosisRecordsForUser:(NSString *)userId; // 删除指定用户的所有诊断记录

// AI诊断功能
- (void)performAIDiagnosisWithSymptoms:(NSString *)symptoms
                            photoPath:(NSString * _Nullable)photoPath
                           completion:(void(^)(NSString *diagnosis, NSString *confidence, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
