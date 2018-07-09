//
//  View.h
//  TestDamo
//
//  Created by Damo on 2018/2/1.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OtherProtocol <NSObject>

- (void)otherMethod;

@end

@protocol SomeProtocol<OtherProtocol>


- (void)someSelector;

@end

IB_DESIGNABLE
@interface View : UIView <SomeProtocol,NSDiscardableContent>

@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSInvocation *invocation;
// 注意: 加上IBInspectable就可以可视化显示相关的属性哦

/** 可视化设置边框颜色 */
@property (nonatomic, strong)IBInspectable UIColor *bgColor;

+ (void)test1;

- (NSNumber *)test2;

- (void)preventInherited;

@end
