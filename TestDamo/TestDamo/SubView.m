//
//  SubView.m
//  TestDamo
//
//  Created by Damo on 2018/2/1.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "SubView.h"
#import <objc/runtime.h>

@implementation SubView

//+ (void)initialize {
// 
//}

void dynamicMethodIMP (id self,SEL _cmd) {
    NSLog(@"This is dynamic method");
}

//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    self.selector = aSelector;
//    NSLog(@"self selector: %s",sel_getName(self.selector));
//    aSelector = @selector(modifySelector);
//    //    if (!_forwardClass) {
//    return [super forwardingTargetForSelector:aSelector];
//    
//    //    }
//    //    return _forwardClass;
//}
//
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(resolveThisMethodDynamically)) {
//        class_addMethod([self class],sel,(IMP) dynamicMethodIMP,"v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}

//- (void)doesNotRecognizeSelector:(SEL)aSelector {
//    [super doesNotRecognizeSelector:aSelector];
//}

- (void)preventInherited {
    NSLog(@"%@ preventInherited ",self);
    [super preventInherited];
}

@end
