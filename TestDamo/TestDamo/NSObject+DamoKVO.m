//
//  NSObject+DamoKVO.m
//  TestDamo
//
//  Created by Damo on 2018/4/2.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "NSObject+DamoKVO.h"
#import <objc/runtime.h>

@implementation NSObject (DamoKVO)

+ (void)load {
    [self swizzingMethod];
}

- (void)addDamo:(NSObject *)observe
        keyPath:(NSString *)keyPath
       opthions:(NSKeyValueObservingOptions)options
        context:(void *)context {
    if (![self observerKeyPath:keyPath observer:observe]) {
        [self addDamo:observe keyPath:keyPath opthions:options context:context];
    }
}

- (void)removeDamo:(NSObject *)observer keyPath:(NSString *)keyPath {
    if ([self observerKeyPath:keyPath observer:observer]) {
        [self removeDamo:observer keyPath:keyPath];
    }
}

// 进行检索获取Key
- (BOOL)observerKeyPath:(NSString *)key observer:(id )observer
{
    id info = self.observationInfo;
    NSArray *array = [info valueForKey:@"_observances"];
    for (id objc in array) {
        id Properties = [objc valueForKeyPath:@"_property"];
        id newObserver = [objc valueForKeyPath:@"_observer"];
        
        NSString *keyPath = [Properties valueForKeyPath:@"_keyPath"];
        if ([key isEqualToString:keyPath] && [newObserver isEqual:observer]) {
            return YES;
        }
    }
    return NO;
}

+ (void)swizzingMethod {
    SEL systemRemoveSel = @selector(removeObserver:forKeyPath:);
    SEL myRemoveSel = @selector(removeDamo:keyPath:);
    SEL systemAddSel = @selector(addObserver:forKeyPath:options:context:);
    SEL myAddSel = @selector(addDamo:keyPath:opthions:context:);
    
    Method systemRemoveMethod = class_getClassMethod([self class], systemRemoveSel);
    Method myRemoveMethod = class_getClassMethod([self class], myRemoveSel);
    Method systemAddMethod = class_getClassMethod([self class], systemAddSel);
    Method myAddMethod = class_getClassMethod([self class], myAddSel);
    
    method_exchangeImplementations(systemRemoveMethod, myRemoveMethod);
    method_exchangeImplementations(systemAddMethod, myAddMethod);
}

@end
