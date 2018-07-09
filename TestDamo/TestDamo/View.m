//
//  View.m
//  TestDamo
//
//  Created by Damo on 2018/2/1.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "View.h"
#import "Model.h"

@interface View()

@end

@implementation View {
    Model *_forwardClass;
}

- (void)someSelector {
    
}

- (void)otherMethod {
    
}

+ (void)initialize {
    if (self == [View self]) {
        
    }
}

- (instancetype)init {
    if (self  = [super init]) {
        _forwardClass = [[Model alloc] init];
    }
    return self;
}

+ (void)load {
    
}

+ (void)test1 {
    
}

- (NSNumber *)test2 {
    return @1;
}

- (void)doSomething {
    NSLog(@"do Somthing was called on %@",[self class]);
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    self.layer.cornerRadius = 30;
    self.layer.masksToBounds = true;
    UILabel *lb = [[UILabel alloc] init];
    lb.backgroundColor = [UIColor blackColor];
    lb.frame = CGRectMake(10, 10, 30, 30);
    [self addSubview:lb];
}


- (void)setBgColor:(UIColor *)bgColor {
    self.backgroundColor = bgColor;
}

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    self.layer.cornerRadius = 30;
//    self.layer.masksToBounds = true;
//
//}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    self.selector = aSelector;
     NSLog(@"self selector: %s",sel_getName(self.selector));
    aSelector = @selector(modifySelector);
    if (!_forwardClass) {
        return [super forwardingTargetForSelector:aSelector];
    
    }
    return _forwardClass;
}

//- (void)modifySelector{
//    NSLog(@"carefully,modified the selecotr");
//}
//
//- (void)preventInherited {
//     NSLog(@"%@ preventInherited ",self);
//    [self doesNotRecognizeSelector:_cmd];
//}
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation {
//    self.invocation = anInvocation;
//    if (!_forwardClass) {
//        [self doesNotRecognizeSelector:[anInvocation selector]];
//    }
//    [anInvocation invokeWithTarget:_forwardClass];
//}
//
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
//    if (!signature) {
//        signature = [_forwardClass methodSignatureForSelector:aSelector];
//    }
//    return signature;
//}

//- (BOOL)beginContentAccess {
//     NSLog(@"%s",__FUNCTION__);
//    printf("beginContentAccess retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
//    return NO;
//}
//- (void)endContentAccess {
//     NSLog(@"%s",__FUNCTION__);
//     printf("endContentAccess retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
//}
//- (void)discardContentIfPossible {
//    NSLog(@"%s",__FUNCTION__);
//    printf("discardContentIfPossible retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
//}
//- (BOOL)isContentDiscarded {
//    NSLog(@"%s",__FUNCTION__);
//    printf("isContentDiscarded retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
//    return NO;
//}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    if (self.subviews.count == 0) {
        return [self replacecdPlacholder:self];
    }
    return self;
}

- (UIView *)replacecdPlacholder:(UIView *)placeholderView {
    NSArray *array = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:nil options:nil];
    UIView *realView = nil;
    for (UIView *view in array) {
        if ([view isKindOfClass:[self class]]) {
            realView = view;
            realView.tag = placeholderView.tag;
            realView.frame = placeholderView.frame;
            realView.bounds = placeholderView.bounds;
            realView.hidden = placeholderView.hidden;
            realView.clipsToBounds = placeholderView.clipsToBounds;
            realView.autoresizingMask = placeholderView.autoresizingMask;
            realView.userInteractionEnabled = placeholderView.userInteractionEnabled;
            realView.translatesAutoresizingMaskIntoConstraints = placeholderView.translatesAutoresizingMaskIntoConstraints;
            if (placeholderView.constraints.count > 0) {
                for (NSLayoutConstraint *constraint in placeholderView.constraints) {
                    NSLayoutConstraint *newConstraint = nil;
                    if (!constraint.secondItem) {
                        newConstraint = [NSLayoutConstraint constraintWithItem:constraint.firstItem
                                                                     attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:nil attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constraint.constant];
                    } else if ([constraint.firstItem isEqualToString:constraint.secondItem]) {
                        newConstraint = [NSLayoutConstraint constraintWithItem:constraint.firstItem attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:constraint.secondItem attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constraint.constant];
                    }
                    if (newConstraint) {
                        newConstraint.shouldBeArchived = constraint.shouldBeArchived;
                        newConstraint.priority = constraint.priority;
                        if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
                            newConstraint.identifier = constraint.identifier;
                        }
                        [realView addConstraint:newConstraint];
                    }
                    
                }
            }
        }
    }
    return realView;
}
    
@end
