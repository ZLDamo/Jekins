//
//  Model.m
//  TestDamo
//
//  Created by Damo on 2018/2/1.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "Model.h"
#import <objc/runtime.h>
#import "TestModel.h"
#import <stdio.h>
#import <stdarg.h>
#import <stdlib.h>

@interface Model() <NSCoding>

@end

@implementation Model {
    NSString *_testName;
}

- (NSString *)info {
    return [NSString stringWithFormat:@"%@,%@",self.name,self.age];
}

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    [self willChangeValueForKey:@"age"];
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[[NSIndexSet alloc] initWithIndex:3]  forKey:@"array"];
    _name = name;
    _age = @"15";
    [_array replaceObjectAtIndex:2 withObject:@"4"];
    [self didChangeValueForKey:@"name"];
    [self didChangeValueForKey:@"age"];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:[[NSIndexSet alloc] initWithIndex:3] forKey:@"array"];
    NSLog(@"%@",self.array);
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

    if ([key isEqualToString:@"info"]) {
        NSArray *affectingKeys = @[@"name", @"age"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;

}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingInfo {
    return [NSSet setWithArray:@[@"name",@"age"]];
}

- (void)removeArrayAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"array"];
    
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"array"];
}
//每个属性都会生成一个方法
+ (BOOL)automaticallyNotifiesObserversOfName {
    return NO;
}

//+ (BOOL)automaticallyNotifiesObserversOfArray {
//    return NO;
//}

//或者使用下面方法关闭自动通知
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    BOOL automatic = NO;
    if ([key isEqualToString:@"name"]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:key];
    }
    return automatic;
}

//+ (NSArray<NSString *> *)classFallbacksForKeyedArchiver {
//    return @[@"TestModel"];
//}



void modelDynamicMethodIMP (id self,SEL _cmd) {
    NSLog(@"This is Model dynamic method");
}

- (instancetype)init {
    if (self = [super init]) {
        self -> _testName = @"str";
//        self.name = @"c";
//        self.age = @"15";
        self.array = [NSMutableArray arrayWithObjects:@"0",@"1",@"2",@"3",nil];
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(resolveThisMethodDynamically)) {
        class_addMethod([self class],sel,(IMP) modelDynamicMethodIMP,"v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

- (void)test {
    [[Model allocWithZone:NULL] init];
}

+ (void)load {
//    [super load];
}

- (void)doSomethingElse {
    NSLog(@"doSomething else  was called on %@",[self class]);
}

- (void)modifySelector{
    NSLog(@"carefully,modified the selecotr");
}


- (void)testRetainCycle:(id)obj {
    NSLog(@"model %@",obj);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.name = [aDecoder decodeObjectForKey:@"name"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
}

//- (id)replacementObjectForCoder:(NSCoder *)aCoder {
//    TestModel *model = [[TestModel alloc] init];;
//    model.name = [aCoder decodeObjectForKey:@"name"];
//    return model;
//}

- (void)debug {
    NSLog(@"debug");
}
@end
