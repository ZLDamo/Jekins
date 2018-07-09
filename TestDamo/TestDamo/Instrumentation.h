//
//  Instrumentation.h
//  TestDamo
//
//  Created by Damo on 2018/2/12.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Instrumentation : NSObject

+ (void)logEvent:(NSString *)name;

+ (void)logEvent:(NSString *)name withParameters:(NSDictionary *)parameters;

@end
