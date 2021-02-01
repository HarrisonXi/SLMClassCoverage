//
//  ViewControllerA.m
//  demo
//
//  Created by HarrisonXi on 2021/2/1.
//

#import "ViewControllerA.h"
#import "SLMClassCoverage.h"

@interface ViewControllerA ()

@end

@implementation ViewControllerA

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)tryClassCoverage {
    [SLMClassCoverage collectData];
    [SLMClassCoverage reportDataWithBlock:^(NSDictionary<NSString *,NSNumber *> *data) {
        NSLog(@"class data: %@", data);
    }];
}

@end
