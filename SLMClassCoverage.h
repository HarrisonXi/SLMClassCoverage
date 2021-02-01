//
//  SLMClassCoverage.h
//  SLMClassCoverage
//
//  Created by HarrisonXi on 2021/2/1.
//

#import <Foundation/Foundation.h>

// all methods is not thread safe, please call them in the same backgroud thread
@interface SLMClassCoverage : NSObject

+ (void)cleanData;
+ (void)collectData;
+ (void)reportDataWithBlock:(void(^)(NSDictionary<NSString *, NSNumber *> *data))block;

@end

