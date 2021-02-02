//
//  SLMClassCoverage.m
//  SLMClassCoverage
//
//  Created by HarrisonXi on 2021/2/1.
//

#import "SLMClassCoverage.h"
#import <objc/runtime.h>

#define FAST_DATA_MASK  0x00007ffffffffff8UL
#define RW_INITIALIZED  (1<<29)

#define Cache_Filepath @"com.harrisonxi.classcoverrage"
#define Auto_Clean_For_App_UPGRADING 1
#define ENABLE_DEBUG_LOG 0

#if ENABLE_DEBUG_LOG > 0
    #define START_EVENT(event) NSDate *event##_startTime = [NSDate date];
    #define END_EVENT(event) NSLog(@"%s: %f", #event, [[NSDate date] timeIntervalSinceDate:event##_startTime]);
#else
    #define START_EVENT(event)
    #define END_EVENT(event)
#endif

@implementation SLMClassCoverage

+ (NSString *)filepath {
    static NSString *filepath_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if (paths && paths.count > 0) {
            filepath_ = [paths.firstObject stringByAppendingPathComponent:Cache_Filepath];
        }
    });
    return filepath_;
}

+ (void)cleanData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager isDeletableFileAtPath:self.filepath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filepath error:nil];
    }
}

static NSMutableDictionary *classesData_ = nil;
+ (void)collectData {
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSString *appBuild = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    if (!classesData_ && [[NSFileManager defaultManager] isReadableFileAtPath:self.filepath]) {
        NSDictionary *dataInfo = [NSDictionary dictionaryWithContentsOfFile:self.filepath];
#if Auto_Clean_For_App_UPGRADING > 0
        NSString *dataVersion = dataInfo[@"version"];
        NSString *dataBuild = dataInfo[@"build"];
        if ([dataVersion isEqualToString:appVersion] && [dataBuild isEqualToString:appBuild]) {
            classesData_ = [dataInfo[@"data"] mutableCopy];
        }
#else
        classesData_ = [dataInfo[@"data"] mutableCopy];
#endif
    }
    if (!classesData_) {
        classesData_ = [NSMutableDictionary dictionary];
    }
    if (classesData_.count == 0) {
        START_EVENT(step1)
        const char *appImage = class_getImageName(self.class);
        unsigned int count = 0;
        Class *classes = objc_copyClassList(&count);
        for (unsigned int index = 0; index < count; index++) {
            Class cls = classes[index];
            const char * image = class_getImageName(cls);
            if (image && strcmp(appImage, image) == 0) {
                // exclude system framework and 3rd framework
                // just scan classes in main bundle
                [classesData_ setObject:@(NO) forKey:NSStringFromClass(cls)];
            }
        }
        free(classes);
        END_EVENT(step1)
    }
    if (classesData_.count > 0) {
        START_EVENT(step2)
        [classesData_ enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull className, NSNumber * _Nonnull initialized, BOOL * _Nonnull stop) {
            if ([initialized boolValue] == NO) {
                Class metaCls = objc_getMetaClass(className.UTF8String);
                // https://opensource.apple.com/source/objc4/objc4-787.1/runtime/objc-runtime-new.h.auto.html
                uint64_t *bits = (__bridge void *)metaCls + 32;
                uint32_t *data = (uint32_t *)(*bits & FAST_DATA_MASK);
                if ((*data & RW_INITIALIZED) > 0) {
                    [classesData_ setObject:@(YES) forKey:className];
                }
            }
        }];
        END_EVENT(step2)
    }
    NSMutableDictionary *dataInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    dataInfo[@"version"] = appVersion;
    dataInfo[@"build"] = appBuild;
    dataInfo[@"data"] = classesData_;
    [dataInfo writeToFile:self.filepath atomically:YES];
}

+ (void)reportDataWithBlock:(void (^)(NSDictionary<NSString *,NSNumber *> *))block {
    block([classesData_ copy]);
}

@end
