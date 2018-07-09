//
//  KVOModel.m
//  TestDamo
//
//  Created by Damo on 2018/4/8.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "KVOModel.h"

@interface KVOModel()
//@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger count;

@end


@implementation KVOModel {
    NSString* toSetName;
    NSString* isName;
    NSString* name;
    NSString* _name;
    NSString* _isName;
    NSArray *_array;
}

- (instancetype)init {
    if (self = [super init]) {
//        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(log) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)log {
// NSLog(@"_name = %@,name = %@,_isName = %@,isName = %@",_name,name,_isName,isName);
     NSLog(@"_name = %@,_isName = %@,isName = %@",_name,_isName,isName);
//  NSLog(@"name = %@,isName = %@",name,isName);
//    NSLog(@"isName = %@",isName);
}

//@synthesize name = _name;

//- (void)set_name:(NSString *)aname {
//    NSLog(@"%s",__FUNCTION__);
//    name = aname;
//}
//
//- (NSString *)_name {
//     NSLog(@"%s",__FUNCTION__);
//    return name;
//}

//- (void)setIsName:(NSString *)isName {
//    NSLog(@"%s",__FUNCTION__);
//    _isName = isName;
//}
//
//- (NSString *)isName {
//    NSLog(@"%s",__FUNCTION__);
//    return _isName;
//}
- (void)setName:(NSString *)name {
    NSLog(@"%s",__FUNCTION__);
    _name = name;
}

//- (NSString *)name {
//     NSLog(@"%s",__FUNCTION__);
//    return _name;
//}

//- (NSString *)getName {
//    NSLog(@"%s",__FUNCTION__);
//    return _name;
//}

//- (NSString *)isName {
//    NSLog(@"%s",__FUNCTION__);
//    return _name;
//}

//- (NSArray *)getArray {
//    NSLog(@"%s",__FUNCTION__);
//    return _array;
//}

//- (NSArray *)array {
//    NSLog(@"%s",__FUNCTION__);
//    return _array;
//}

- (NSArray *)isArray {
    NSLog(@"%s",__FUNCTION__);
    return _array;
}

- (void)incrementCount{
    self.count ++;
}

- (NSUInteger)countOfNumbers{
    NSLog(@"%s",__FUNCTION__);
    return 7;
}
-(id)objectInNumbersAtIndex:(NSUInteger)index{     //当key使用numbers时，KVC会找到这两个方法。
    NSLog(@"%s",__FUNCTION__);
    return @(index * 3);
}
    

- (NSArray *)arrayAtIndexes {
    NSLog(@"%s",__FUNCTION__);
    return nil;
}

//- (void)set_name:(NSString *)name {
//    NSLog(@"%s",__FUNCTION__);
//    _isName = name;
//}

- (id)valueForKey:(NSString *)key {
    NSLog(@"key = %@",key);
  return [super valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
     NSLog(@"%s,key = %@",__FUNCTION__,key);
}

- (id)valueForUndefinedKey:(NSString *)key {
     NSLog(@"%s,key = %@",__FUNCTION__,key);
    return nil;
}

+ (BOOL)accessInstanceVariablesDirectly {
     NSLog(@"%s",__FUNCTION__);
     return YES;
}

@end
