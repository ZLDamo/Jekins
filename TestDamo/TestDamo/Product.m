//
//  Product.m
//  TestDamo
//
//  Created by Damo on 2018/4/10.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "Product.h"

@interface Product()

@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSMutableArray *collectorArr;
@property (nonatomic, assign) BOOL shouldProduce;


@end

@implementation Product {
}

- (instancetype)initWithCondition:(NSCondition *)condition collectorArr:(NSMutableArray *)collector {
    if (self  = [super init]) {
        self.condition = condition;
        self.collectorArr = collector;
    }
    return self;
}

- (void)setShouldProduce:(BOOL)shouldProduce {
    _shouldProduce = shouldProduce;
    NSLog(@"shouldProduct = %d",_shouldProduce);
}

- (void)product {
    self.shouldProduce = YES;
    while (self.shouldProduce) {
        [self.condition lock];
        if (self.collectorArr.count > 0) {
            [self.condition wait];
        }
        sleep(4);
        NSLog(@"%s",__FUNCTION__);
        [self.collectorArr addObject:[[Product alloc] init]];
        [self.condition signal];
        [self.condition unlock];
    }
}

@end
