//
//  Custom.m
//  TestDamo
//
//  Created by Damo on 2018/4/10.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "Consumer.h"

@interface Consumer()

@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSMutableArray *collectorArr;
@property (nonatomic, assign) BOOL shouldCustom;

@end

@implementation Consumer

- (instancetype)initWithCondition:(NSCondition *)condition collectorArr:(NSMutableArray *)collector {
    if (self  = [super init]) {
        self.condition = condition;
        self.collectorArr = collector;
    }
    return self;
}

- (void)product {
    self.shouldCustom = YES;
    while (self.shouldCustom) {
        [self.condition lock];
        if (self.collectorArr.count == 0) {
            [self.condition wait];
        }
        [self.collectorArr removeObjectAtIndex:0];
        [self.condition signal];
        [self.condition unlock];
    }
}


@end
