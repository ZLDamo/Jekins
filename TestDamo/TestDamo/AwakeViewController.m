//
//  AwakeViewController.m
//  TestDamo
//
//  Created by Damo on 2018/3/7.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "AwakeViewController.h"
#import "Model.h"
#import "KVOModel.h"
#import <objc/runtime.h>
#import "Product.h"
#import "Consumer.h"

@interface Book : NSObject
@property (nonatomic,copy)  NSString* name;
@property (nonatomic,assign)  CGFloat price;
@end
@implementation Book

//- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable __autoreleasing *)outError {
//    NSString *name = *ioValue;
//    name = name.capitalizedString;
//    if ([name isEqualToString:@"James"]) {
//        return NO;
//    }
//    return YES;
//}

@end

@interface AwakeViewController () <UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) Model *model;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Model *aModel;
@property (nonatomic, copy) void(^block)();
@property (nonatomic,   weak) UIAlertController *alertVC;
@property (nonatomic, strong) NSTimer* tiemr;
@property (nonatomic, strong) id target;
@property (nonatomic, strong) NSHashTable *hashTable;
@end

static void * kNameKey = &kNameKey;
@implementation AwakeViewController


void logName(id self,SEL _cmd) {
    AwakeViewController *vc = objc_getAssociatedObject(self, "name");
    NSLog(@"%@",vc.name);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name = @"name";
    self.model = [[Model alloc] init];
//    self.aModel = [[Model alloc] init];
//    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
//    self.model.name = self.name;
//    self.model.objc = self.aModel;
//    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
//    self.block = ^{
//        NSLog(@"%@",self);
//    };
//    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
//    self. block();
//    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
//    [self testKvo];
//    [self testKVC];
//    [self testProductConsumerModel];
    self.target = [NSObject new];
//    class_addMethod([_target class], @selector(logName), (IMP)logName, "V@:");
//    objc_setAssociatedObject(self.target, "name", self, OBJC_ASSOCIATION_ASSIGN);
//    self.tiemr = [NSTimer timerWithTimeInterval:1.0 target:self.target selector:@selector(logName) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.tiemr forMode:NSDefaultRunLoopMode];
    
    Model *otherM = [Model new];
    NSHashTable *hashTabel = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:3];
    self.hashTable = hashTabel;
    [hashTabel addObject:self.target];
    [hashTabel addObject:otherM];
    [hashTabel addObject:self.model];
    NSLog(@"%@",_hashTable.allObjects);
    
    NSMapTable *mapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:4];
    [mapTable setObject:otherM forKey:@"model"];
    [mapTable setObject:self.model forKey:@"model"];
    [mapTable setObject:self.target forKey:@"target"];
    id obj       = [mapTable objectForKey:@"model"];
    NSArray *arr = mapTable.keyEnumerator.allObjects;
    arr          = mapTable.objectEnumerator.allObjects;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@",_hashTable);
}

- (void)testProductConsumerModel {
    NSMutableArray *array = [NSMutableArray array];
    NSCondition *condition = [[NSCondition alloc] init];
    Product *product = [[Product alloc] initWithCondition:condition collectorArr:array];
    Consumer *consumer = [[Consumer alloc] initWithCondition:condition collectorArr:array];
    [NSThread detachNewThreadSelector:@selector(product) toTarget:product withObject:nil];
    [NSThread detachNewThreadSelector:@selector(consum) toTarget:consumer withObject:nil];

    [condition broadcast];
}

- (void)testKVC {
    NSArray* arrStr = @[@"english",@"franch",@"chinese"];
    NSArray* arrCapStr = [arrStr valueForKey:@"capitalizedString"];
    for (NSString* str in arrCapStr) {
        NSLog(@"%@",str);
    }
    NSArray* arrCapStrLength = [arrStr valueForKeyPath:@"capitalizedString.length"];
    for (NSNumber* length in arrCapStrLength) {
        NSLog(@"%ld",(long)length.integerValue);
    }
    
    Book *book1 = [Book new];
    book1.name = @"The Great Gastby";
    book1.price = 22;
    
    NSString *name = @"James";
    BOOL result = [book1 validateValue:&name forKey:@"nn" error:nil];
    if (result) {
        [book1 setValue:name forKey:@"name"];
    } else {
        NSLog(@"非法值");
    }
    
    Book *book2 = [Book new];
    book2.name = @"Time History";
    book2.price = 12;
    Book *book3 = [Book new];
    book3.name = @"Wrong Hole";
    book3.price = 111;
    
    Book *book4 = [Book new];
    book4.name = @"Wrong Hole";
    book4.price = 111;
    
    NSArray* arrBooks = @[book1,book2,book3,book4];
    NSNumber* sum = [arrBooks valueForKeyPath:@"@sum.price"];
    NSLog(@"sum:%f",sum.floatValue);
    NSNumber* avg = [arrBooks valueForKeyPath:@"@avg.price"];
    NSLog(@"avg:%f",avg.floatValue);
    NSNumber* count = [arrBooks valueForKeyPath:@"@count"];
    NSLog(@"count:%f",count.floatValue);
    NSNumber* min = [arrBooks valueForKeyPath:@"@min.price"];
    NSLog(@"min:%f",min.floatValue);
    NSNumber* max = [arrBooks valueForKeyPath:@"@max.price"];
    NSLog(@"max:%f",max.floatValue);
    
    NSLog(@"distinctUnionOfObjects");
    NSArray* arrDistinct = [arrBooks valueForKeyPath:@"@distinctUnionOfObjects.price"];
    for (NSNumber *price in arrDistinct) {
        NSLog(@"%f",price.floatValue);
    }
    
    NSArray *array  = @[@"12-11",@"12-13",@"12-11"];
    NSArray *resultArr = [array valueForKeyPath:@"@distinctUnionOfObjects.self"];
    NSLog(@"unionOfObjects");
    NSArray* arrUnion = [arrBooks valueForKeyPath:@"@unionOfObjects.price"];
    for (NSNumber *price in arrUnion) {
        NSLog(@"%f",price.floatValue);
    }
}

- (void)testKvo {
    
    KVOModel *model = [[KVOModel alloc] init];
//    [model setValue:@"damo" forKey:@"name"];
//    NSString *name = [model valueForKey:@"name"];
    NSArray *arr = @[@1];
    [model setValue:arr forKey:@"array"];
   id obj = [model valueForKey:@"numbers"];
    NSLog(@"%@",NSStringFromClass([obj class]));
    NSLog(@"0:%@    1:%@     2:%@     3:%@",obj[0],obj[1],obj[2],obj[3]);
//    NSString *_name = [model valueForKey:@"_name"];
//    NSString *isName = [model valueForKey:@"isName"];
//    NSString *_isName = [model valueForKey:@"_isName"];
//    NSLog(@"name = %@,_name = %@,isName = %@,_isName = %@",name,_name,isName,_isName);
    
    //KVO
//    [model addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
//    NSLog(@"model -addKVO%@",object_getClass(model));
//    NSLog(@"setterAdress-addKVO: %p \n", [model methodForSelector:@selector(setName:)]);
//    [model removeObserver:self forKeyPath:@"name"];
//    NSLog(@"model -removeKVO:%@",object_getClass(model));
//    NSLog(@"setterAdress-removeKVO: %p \n", [model methodForSelector:@selector(setName:)]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.tiemr invalidate];
    self.tiemr = nil;
     NSLog(@"%s",__FUNCTION__);
}

@end
