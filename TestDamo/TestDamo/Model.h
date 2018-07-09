//
//  Model.h
//  TestDamo
//
//  Created by Damo on 2018/2/1.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Model : NSObject <NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) id objc;
@property (nonatomic, strong) NSMutableArray *array;

- (void)testRetainCycle:(id)obj;
- (void)debug;
@end
