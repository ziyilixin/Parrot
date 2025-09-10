//
//  DiagnosisRecord.m
//  Parrot
//
//  Created by WCF on 2025/9/10.
//

#import "DiagnosisRecord.h"

@implementation DiagnosisRecord

- (instancetype)initWithSymptoms:(NSString *)symptoms
                      photoPath:(NSString *)photoPath
                   aiDiagnosis:(NSString *)aiDiagnosis
                    confidence:(NSString *)confidence {
    if (self = [super init]) {
        self.recordId = [[NSUUID UUID] UUIDString];
        self.symptoms = symptoms;
        self.photoPath = photoPath;
        self.aiDiagnosis = aiDiagnosis;
        self.confidence = confidence;
        self.createdDate = [NSDate date];
        self.updatedDate = [NSDate date];
    }
    return self;
}

+ (instancetype)fromDictionary:(NSDictionary *)dict {
    DiagnosisRecord *record = [[DiagnosisRecord alloc] init];
    record.recordId = dict[@"recordId"];
    record.userId = dict[@"userId"];
    record.symptoms = dict[@"symptoms"];
    record.photoPath = dict[@"photoPath"];
    record.aiDiagnosis = dict[@"aiDiagnosis"];
    record.confidence = dict[@"confidence"];
    
    // 转换时间戳
    if (dict[@"createdDate"]) {
        record.createdDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"createdDate"] doubleValue]];
    }
    if (dict[@"updatedDate"]) {
        record.updatedDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"updatedDate"] doubleValue]];
    }
    
    return record;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"recordId"] = self.recordId ?: @"";
    dict[@"userId"] = self.userId ?: @"";
    dict[@"symptoms"] = self.symptoms ?: @"";
    dict[@"photoPath"] = self.photoPath ?: @"";
    dict[@"aiDiagnosis"] = self.aiDiagnosis ?: @"";
    dict[@"confidence"] = self.confidence ?: @"";
    dict[@"createdDate"] = @([self.createdDate timeIntervalSince1970]);
    dict[@"updatedDate"] = @([self.updatedDate timeIntervalSince1970]);
    return [dict copy];
}

@end
