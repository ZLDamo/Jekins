//
//  NSObject+Swizzling.m
//  TestDamo
//
//  Created by Damo on 2018/5/18.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import <objc/runtime.h>

@implementation UIViewController (Swizzling)

+ (void)load {
    Class originalClass = NSClassFromString(@"ViewController");
//    Class swizzledClass = [self class];
    SEL originalSelector = NSSelectorFromString(@"run:");
    SEL swizzledSelector = @selector(xxx_run:str:);
//    unsigned int outCount;
//    Method *list = class_copyMethodList(self, &outCount);
//    for (int i = 0; i < outCount; i++) {
//        Method m = list[i];
//        NSLog(@"list = %@",NSStringFromSelector(method_getName(m)));
//    }
//    free(list);
    
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(originalClass, swizzledSelector);
    
    // 向Car类中新添加一个xxx_run:的方法
//    BOOL registerMethod = class_addMethod(self,
//                                          swizzledSelector,
//                                          method_getImplementation(swizzledMethod),
//                                          method_getTypeEncoding(swizzledMethod));
//    if (!registerMethod) {
//        return;
//    }
//
//    // 需要更新swizzledMethod变量,获取当前Car类中xxx_run:的Method指针
//    swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
//    if (!swizzledMethod) {
//        return;
//    }
    
    // 后续流程与之前的一致
    BOOL didAddMethod = class_addMethod(originalClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(originalClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (NSString *)xxx_run:(double)speed str:(NSString *)o{
    if (speed < 120) {
        [self xxx_run:speed str:o];
        
    }
    NSLog(@"swizzling run");
    return @"swizzling";
}


@end
