//
//  Instrumentation.m
//  TestDamo
//
//  Created by Damo on 2018/2/12.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "Instrumentation.h"
#import <Flurry.h>

@implementation Instrumentation

+ (void)logEvent:(NSString *)name {
    NSLog(@"%@",name);
    [Flurry logEvent:name];
}

+ (void)logEvent:(NSString *)name withParameters:(NSDictionary *)parameters {
    NSLog(@"%@ -> %@",name,parameters);
    [Flurry logEvent:name withParameters:parameters];
}

@end
