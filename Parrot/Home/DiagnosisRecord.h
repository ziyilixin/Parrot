//
//  DiagnosisRecord.h
//  Parrot
//
//  Created by WCF on 2025/9/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DiagnosisRecord : NSObject

@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *symptoms; // 症状描述（必填）
@property (nonatomic, strong) NSString *photoPath; // 照片路径（可选）
@property (nonatomic, strong) NSString *aiDiagnosis; // AI诊断结果
@property (nonatomic, strong) NSString *confidence; // 置信度
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSDate *updatedDate;

// 初始化方法
- (instancetype)initWithSymptoms:(NSString *)symptoms
                      photoPath:(NSString * _Nullable)photoPath
                   aiDiagnosis:(NSString *)aiDiagnosis
                    confidence:(NSString *)confidence;

// 字典转换方法
+ (instancetype)fromDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
