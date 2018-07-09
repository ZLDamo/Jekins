//
//  Custom.h
//  TestDamo
//
//  Created by Damo on 2018/4/10.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Consumer : NSObject

@property (nonatomic, assign) BOOL shouldCustom;

- (instancetype)initWithCondition:(NSCondition *)condition collectorArr:(NSMutableArray *)collector;

- (void)consum;

@end
