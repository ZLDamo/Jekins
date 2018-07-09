//
//  SSubView.m
//  TestDamo
//
//  Created by Damo on 2018/2/1.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "SSubView.h"
#define toString(a) #a
#define printSquare(x) printf("the square of " #x " is %d.\n",(x) * (x))
#define combin(a,b) a##b
#define addPrefixForVar(a) mk_##a
#define formart(formart,...) [NSString stringWithFormat:formart,##__VA_ARGS__]

#ifdef DEBUG
#define NSLog(format,...)  NSLog(format,##__VA_ARGS__)
#else
#define NSLog(formart,...)
#endif

@implementation SSubView

__attribute((overloadable)) static inline NSString *test(NSString *str) {
    
    return @"hah";
}

__attribute((overloadable)) static inline BOOL checkNet(NSString *str) {
    return [[[SSubView alloc] init] checkNet:str];
}

+ (void)initialize {
    
}

+ (void)load {
    BOOL result = checkNet(@"str");
    NSLog(@"resutl = %d",result);
    NSString *str = test(@"");
    NSLog(@"reload = %@",str);
    NSLog(@"toStr = %s\n",toString(abc));
    printSquare(3);
    NSLog(@"combin = %d",combin(34, 57));
    int mk_x = 30;
    NSLog(@"%d",addPrefixForVar(x));
    str = formart(@"%@-%@-%@",@"G",@"X",@"G");
    NSLog(@"format = %@",str);
}

- (BOOL)checkNet:(NSString *)str {
    if (str) return  YES;
    return  NO;
}

- (NSString *)test:(NSString *)str {
    return @"";
}

@end
