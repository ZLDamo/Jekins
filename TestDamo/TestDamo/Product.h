//
//  Product.h
//  TestDamo
//
//  Created by Damo on 2018/4/10.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

//@property (nonatomic, assign) BOOL shouldProduce;

- (instancetype)initWithCondition:(NSCondition *)condition collectorArr:(NSMutableArray *)collector;
- (void)product;
@end
