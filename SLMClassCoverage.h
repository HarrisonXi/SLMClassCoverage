//
//  SLMClassCoverage.h
//  SLMClassCoverage
//
//  Created by HarrisonXi on 2021/2/1.
//  Copyright © 2021 harrisonxi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// all methods is not thread safe, please call them in the same backgroud thread
API_AVAILABLE(ios(13.0)) @interface SLMClassCoverage : NSObject

+ (void)cleanData;
+ (void)collectData;
+ (void)reportDataWithBlock:(void(^)(NSDictionary<NSString *, NSNumber *> *data))block;

@end

NS_ASSUME_NONNULL_END
