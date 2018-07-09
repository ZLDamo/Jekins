//
//  TestModel.m
//  TestDamo
//
//  Created by Damo on 2018/3/26.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "TestModel.h"

@interface TestModel() <NSCoding>

@end

@implementation TestModel

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.name = [aDecoder decodeObjectForKey:@"name"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (NSArray <NSString *> *)attributeKeys {
    return @[@"name",@"grade"];
}

//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:self.name forKey:@"name"];
//}

@end
