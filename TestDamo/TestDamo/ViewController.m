//
//  ViewController.m
//  TestDamo
//
//  Created by Damo on 2018/1/26.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "ViewController.h"
#import "View.h"
#import "Model.h"
#import "SSubView.h"
//#import "Instrumentation.h"
#import "UIImage+Processor.h"
#import "AwakeViewController.h"
#import "CameraViewController.h"
//#import "Model.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "TestModel.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "UIViewController+Swizzling.h"
#import <objc/message.h>
#import "TestProtocol.h"

#define TEST_NOTIFICATION @"TEST_NOTIFICATION"

@protocol AddProtocol <NSObject>

- (void)addProtocolMethod;

@end


@interface ViewController ()<NSMachPortDelegate>

@property (nonatomic,   weak) UIView *weakView;
//@property NSString *newTitle;
@property (getter=getNewTitle) NSString *newTitle;
@property (weak, nonatomic) IBOutlet View *aView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *textLb;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) Model *model;
@property (nonatomic, copy) NSMutableArray *array;
@property (nonatomic, strong) CameraViewController *cameraVC;
@property (nonatomic,   weak) NSString      *weakStr;

@property (nonatomic) NSMutableArray    *notifications;         // 通知队列
@property (nonatomic) NSThread          *notificationThread;    // 期望线程
@property (nonatomic) NSLock            *notificationLock;      // 用于对通知队列加锁的锁对象，避免线程冲突
@property (nonatomic) NSMachPort        *notificationPort;      // 用于向期望线程发送信号的通信端口


@end

static NSString *name = @"a";

@implementation ViewController {
    NSLock *_lock;
}

+ (void)load {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    _newTitle = @"new";
    _weakStr = @"weak";
    _model = [[Model alloc] init];
    
    self.navigationController.navigationBar.translucent = false;
    self.view.backgroundColor = [UIColor whiteColor];
    [self buttonClick:nil];
//     [self testSign];
//    [self testDoesNotRecognizeSelector];
//    [self testPreventInherited];
//    [self.navigationController pushViewController:[[AwakeViewController alloc] init] animated:YES];
//    [self testRetainCycle];
//    [self testRootViewController];
//    [self testModelDecode];
//    [self testThread];
//    [self test3DTouch];
//    [self testAg];
//    [self testKVO];
//   NSInteger index = [self indexOfAccessibilityElement:self.newTitle];
    [self testRuntime];
//    [self testNSDecimalNumber];
//    [self testNotificationAsyn];
    [self testNSDecimalNumber];
}

- (void)testNotificationAsyn {
    
//   1.
//   current thread = <NSThread: 0x60400006cd80>{number = 1, name = main}
//   current thread = <NSThread: 0x604000267700>{number = 3, name = (null)}
//    NSLog(@"current thread = %@", [NSThread currentThread]);
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:TEST_NOTIFICATION object:nil];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:TEST_NOTIFICATION object:nil userInfo:nil];
//    });
    
    //2
    NSLog(@"current thread = %@", [NSThread currentThread]);
    
    // 初始化
    self.notifications = [[NSMutableArray alloc] init];
    self.notificationLock = [[NSLock alloc] init];
    
    self.notificationThread = [NSThread currentThread];
    self.notificationPort = [[NSMachPort alloc] init];
    self.notificationPort.delegate = self;
    
    // 往当前线程的run loop添加端口源
    // 当Mach消息到达而接收线程的run loop没有运行时，则内核会保存这条消息，直到下一次进入run loop
    [[NSRunLoop currentRunLoop] addPort:self.notificationPort
                                forMode:(__bridge NSString *)kCFRunLoopCommonModes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:TEST_NOTIFICATION object:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TEST_NOTIFICATION object:nil userInfo:nil];
        
    });
    [self run:110];
}


- (void)run:(double)speed {
    NSLog(@"%s",__FUNCTION__);
}

//- (void)handleNotification:(NSNotification *)notification
//{
//    NSLog(@"current thread = %@", [NSThread currentThread]);
//
//    NSLog(@"test notification");
//}

- (void)handleMachMessage:(void *)msg {
    
    [self.notificationLock lock];
    
    while ([self.notifications count]) {
        NSNotification *notification = [self.notifications objectAtIndex:0];
        [self.notifications removeObjectAtIndex:0];
        [self.notificationLock unlock];
        [self processNotification:notification];
        [self.notificationLock lock];
    };
    
    [self.notificationLock unlock];
}

- (void)processNotification:(NSNotification *)notification {
    
    if ([NSThread currentThread] != _notificationThread) {
        // Forward the notification to the correct thread.
        [self.notificationLock lock];
        [self.notifications addObject:notification];
        [self.notificationLock unlock];
        [self.notificationPort sendBeforeDate:[NSDate date]
                                   components:nil
                                         from:nil
                                     reserved:0];
    }
    else {
        // Process the notification here;
        NSLog(@"current thread = %@", [NSThread currentThread]);
        NSLog(@"process notification");
    }
}


- (void)testRuntime {
   const char *className = class_getName([self class]);
    NSString *aclass = [NSString stringWithCString:className encoding:NSUTF8StringEncoding];
    NSLog(@"char = %s,NSString = %@",className,aclass);

    Class superVC = class_getSuperclass([self class]);
    Class superNSObject = class_getSuperclass([NSObject class]);
    NSLog(@"superVC = %@,superNSObject = %@",superVC,superNSObject);
    
    Class metaClass = object_getClass([self class]);
    BOOL isMeta1 = class_isMetaClass(metaClass);
    BOOL isMeta2 = class_isMetaClass([self class]);
    NSLog(@"isMeta1 = %d,isMeta2 = %d",isMeta1,isMeta2);
    
    size_t size =  class_getInstanceSize([self class]);
    size_t result = sizeof([self class]);
    NSLog(@"size  = %zu,result = %zu",size,result);
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i =0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        NSLog(@"name = %s,type = %s",name,type);
    }
    free(ivars);
    
    Ivar ivar = class_getInstanceVariable([self class], "_lock");
    id getIvar = object_getIvar(self, ivar);
    NSLog(@"getIvar = %@",getIvar);
    
    //取的值为nil,?
    ivar = class_getClassVariable([self class], "name");
    getIvar = object_getIvar(self, ivar);
    NSLog(@"getIvar = %@",getIvar);
    
   Class dynamicClass = objc_allocateClassPair(NSObject.class, "DynamicClass", 0);
   BOOL result1 =  class_addIvar(dynamicClass, "_name", sizeof(id), log2(sizeof(id)), @encode(id));
   BOOL result2 = class_addIvar(dynamicClass, "_age", sizeof(unsigned int), log2(sizeof(unsigned int)), 0);
    objc_registerClassPair(dynamicClass);
    
    id aobj = [[dynamicClass alloc] init];
    [aobj setValue:@"Damo" forKey:@"_name"];
    Ivar age = class_getInstanceVariable(dynamicClass, "_age");
    object_setIvar(aobj, age, @18);
    NSLog(@"DynamicClass property name = %@,age = %@",[aobj valueForKey:@"name"],object_getIvar(aobj, age));
    // 当类或者它的子类的实例还存在，则不能调用objc_disposeClassPair方法
    aobj = nil;
    
    // 销毁类
    objc_disposeClassPair(dynamicClass);
    
    
//    const uint8_t *ivarLayout = class_getIvarLayout([self class]);
//    const uint8_t *weakIvarLayout = class_getWeakIvarLayout([self class]);
    printf("strong:\n");
    const uint8_t *array_s = class_getIvarLayout([self class]);
    int i = 0;
    uint8_t value_s = array_s[i];
    while (value_s != 0x0) {
        printf("\\x%02x\n", value_s);
        value_s = array_s[++i];
    }
    
    printf("----------\n");
    
    printf("weak:\n");
    const uint8_t *array_w = class_getWeakIvarLayout([self class]);
    int j = 0;
    uint8_t value_w = array_w[j];
    while (value_w != 0x0) {
        printf("\\x%02x\n", value_w);
        value_w = array_w[++j];
    }
    
   objc_property_t newtitle = class_getProperty(self.class, "newTitle");
    NSLog(@"property newtitle = %s",property_getName(newtitle));
    
   objc_property_t *properties = class_copyPropertyList(self.class, &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        NSLog(@"property = %s",property_getName(property));
    }
    free(properties);
    
    
    Method test1 = class_getInstanceMethod(self.class, @selector(testAg));
    Method testMeat = class_getClassMethod(self.class, @selector(testMeta));
    [self testAg];
    [self.class testMeta];
    method_exchangeImplementations(test1, testMeat);
    [self testAg];
    [self.class testMeta];
    
    
   Method *methodList = class_copyMethodList(self.class, &count);
    for (int i = 0;i < count;i++) {
        Method method = methodList[i];
        SEL selector = method_getName(method);
        const char *type = method_getTypeEncoding(method);
        char *copyType = method_copyReturnType(method);
        char *argumentType = method_copyArgumentType(method, 0);
        char dst;
        method_getReturnType(method, &dst, sizeof(dst));
        NSLog(@"selector = %@,type = %s,copyType = %s,argumentType = %s,returnType = %c\n\n",NSStringFromSelector(selector),type,copyType,argumentType,dst);
        
        free(argumentType);
        free(copyType);
    }
    free(methodList);
    [[View new] performSelector:@selector(doSomethingElse)];
    IMP imp = class_getMethodImplementation([View class], @selector(doSomethingElse));
//    IMP aimp = class_getMethodImplementation_stret([View class], @selector(doSomethingElse));
    BOOL re = class_respondsToSelector(View.class, @selector(test2));
    
    BOOL re1 = class_addProtocol(self.class, @protocol(AddProtocol));
    re1 = class_conformsToProtocol(self.class, @protocol(AddProtocol));
    
    [self dynamic2];
    
    Protocol * __unsafe_unretained * proList = class_copyProtocolList(self.class, &count);
    for (int i = 0; i < count; i++) {
        Protocol *pro = proList[i];
        NSLog(@"protocol list = %s",protocol_getName(pro));
    }
    free(proList);
    
    int version = class_getVersion(self.class);
    class_setVersion(self.class, 99);
    version = class_getVersion(self.class);
    
    
    id theObject = class_createInstance(NSString.class, sizeof(unsigned));
    id str1 = [theObject init];
    
    NSLog(@"%@", [str1 class]);
    
    id str2 = [[NSString alloc] initWithString:@"test"];
    NSLog(@"%@", [str2 class]);
    
    
   size_t dd = class_getInstanceSize(self.class);
    
    Ivar iva = class_getInstanceVariable(self.class, "_weakStr");
    id o = object_getIvar(self, iva);
    object_setIvar(self, iva, @"weak");
    NSLog(@"_weakStr = %@",_weakStr);
    
    const char *name = object_getClassName(self.class);
    
    Class myclass = object_getClass(self);
    BOOL isClass = object_isClass(_weakStr);
    Class cl = object_setClass(_weakStr, [[NSMutableString string] class]);
    NSLog(@"%@",[_weakStr class]);
   
    int numClasses ;
    Class *classes = NULL;
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        classes =(Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes,numClasses);
        free(classes);
    }
    
   classes = objc_copyClassList(&count);
    
    free(classes);
    classes = nil;
    
    Class c1 = objc_lookUpClass("Mode");
    Class c2 = objc_getClass("Mode");
    Class c3 = objc_getRequiredClass("Model");
    Class c4 = objc_getMetaClass("Mode");
    
    Ivar *ivas = class_copyIvarList(self.class, &count) ;
    for (int i = 0; i < count; i++ ) {
        Ivar iva = ivas[i];
        const char *name = ivar_getName(iva);
        const char *encoding = ivar_getTypeEncoding(iva);
        ptrdiff_t offset = ivar_getOffset(iva);
        NSLog(@"Ivar = %s,typeEncoding = %s,offset = %td",name,encoding,offset);
    }
    free(ivas);
    
    static const void *key = &key;
    objc_setAssociatedObject(self, key, @"value", OBJC_ASSOCIATION_RETAIN);
    NSString *value = objc_getAssociatedObject(self, key);
    objc_removeAssociatedObjects(self);
    
   
    const char **imageNames = objc_copyImageNames(&count);
    for (int i = 0; i < count; i ++) {
        const char *imageName =  imageNames[i];
        NSLog(@"imageName = %s\n\n",imageName);
    }
    const char *class_img = class_getImageName(self.class);
    free(imageNames);

    NSLog(@"UIView's Framework: %s", class_getImageName(NSClassFromString(@"UIView")));
    NSLog(@"获取指定库或框架中所有类的类名");
    const char ** classes1 = objc_copyClassNamesForImage(class_getImageName(NSClassFromString(@"UIView")), &count);
    for (int i = 0; i < count; i++) {
        NSLog(@"class name: %s", classes1[i]);
    }
    free(classes1);
//    method_invoke()
    
    Model *model = [[Model alloc] init];
//   const char *str = sel_getName(@selector(testAg));
//   SEL sel1 = sel_registerName("abd");
    NSLog(@"sel = %@",NSStringFromSelector(NSSelectorFromString(@"abd")));
//    SEL sel2 = sel_getUid("csd");
    NSLog(@"sel2 = %@",NSStringFromSelector(NSSelectorFromString(@"csd")));
    class_addMethod([self class], NSSelectorFromString(@"abd"), (IMP)addtestMethod, "v@:");
    [self performSelector:NSSelectorFromString(@"abd")];
    
//    int count = 0;
    objc_property_attribute_t attrs[] = { { "T", "@\"NSString\"" }, { "&", "N" }, { "V", "" } };
    Protocol *myProtocol = objc_allocateProtocol("MyProtocol");
    protocol_addProperty(myProtocol, "age", attrs, 3, YES, YES);
    protocol_addProperty(myProtocol, "aclass", attrs, 3, YES, YES);
    //已注册的协议,不能添加
    
    NSLog(@"%@",[self remoteProtocolForName:@"TestProtocol"]);
    protocol_addMethodDescription(myProtocol, NSSelectorFromString(@"abd"), "v@:", YES, YES);
    protocol_addProtocol(myProtocol, NSProtocolFromString(@"TestProtocol"));
    objc_registerProtocol(myProtocol);
    BOOL r = class_addProtocol([model class], myProtocol);
    NSLog(@"model conforms to protocol = %d",[model conformsToProtocol:myProtocol]);
    objc_property_t *propertys = protocol_copyPropertyList(myProtocol, &count);
    for (int i = 0 ; i < count; i ++) {
        objc_property_t property = propertys[i];
        int outCount;
//        objc_property_attribute_t * attrs = property_copyAttributeList(property, &outCount);
//        for (int i = 0 ; i < outCount; i ++) {
        const char * attr = property_getAttributes(property);
//        }
        NSLog(@"attr = %s",attr);
        NSLog(@"myprotocol property = %s",property_getName(property));
    }
    free(propertys);
    
    Protocol * __unsafe_unretained _Nonnull * _Nullable protocols =  protocol_copyProtocolList(myProtocol, &count);
    for (int i = 0; i < count;i++) {
        Protocol *p = protocols[i];
        NSLog(@"myprotocol protocol = %s",protocol_getName(p));
    }
    free(protocols);
    
    struct objc_method_description *methods =  protocol_copyMethodDescriptionList(myProtocol, YES, YES, &count);
    for (int i = 0 ; i< count; i ++) {
        struct objc_method_description method = methods[i];
        NSLog(@"myprotocol method = %@",NSStringFromSelector(method.name));
    }
    free(methods);
    
   objc_property_t p = protocol_getProperty(myProtocol, "age", YES, YES);
   struct objc_method_description m = protocol_getMethodDescription(myProtocol, @selector(abd), YES, YES);
   BOOL isEqual = protocol_isEqual(myProtocol, NSProtocolFromString(@"TestProtocol"));
   BOOL isConform =  protocol_conformsToProtocol(myProtocol, NSProtocolFromString(@"TestProtocol"));
   
   
    void (*funcVoidVoid)() = &voidVoidTest;
    objc_setEnumerationMutationHandler(funcVoidVoid);
    NSString *str = @"test";
    objc_enumerationMutation(str);
//    NSHashTable;
//    NSMapTable;
    
    model.name = @"james";model.age = @"13";
    IMP aimp = imp_implementationWithBlock(^(id obj,NSString *args1,NSString *args2) {
        NSLog(@"%@-%@",args1,args2);
    });
    class_addMethod(model.class, @selector(debugLog::), aimp, "V@:");
    [model performSelector:@selector(debugLog::) withObject:model.name withObject:model.age];
    id impBlock = imp_getBlock(aimp);
    imp_removeBlock(aimp);
    
}

void voidVoidTest(id objt) {
    NSLog(@"%@挂啦",objt);
}





- (Protocol *)remoteProtocolForName:(NSString *)name
{
    static NSDictionary *dict = nil;
    if (!dict)
    {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                @protocol(TestProtocol), @"TestProtocol",nil];
    }
    return [dict objectForKey:name];
}

void addtestMethod(id self,SEL _cmd) {
    NSLog(@"%s",__FUNCTION__);
}


- (void)testLock {
    static int count = 0;
    [_lock lock];
    count ++;
    NSLog(@"%d",count);
    return
    [_lock unlock];
}

- (void)dynamic2{
    
    unsigned int count;
    
    //在运行时创建继承自NSObject的People类
    Class People = objc_allocateClassPair([NSObject class], "People", 0);
    
    NSString *proName = @"pro";
    
    //完成People类的创建
    class_addIvar(People, [proName cStringUsingEncoding:NSUTF8StringEncoding], sizeof(NSString *), log2(sizeof(NSString*)), @encode(NSString*));
    objc_registerClassPair(People);
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t attribute2 = {"N",""};//value无意义时通常设置为空
    objc_property_attribute_t ownership = { "C", "" };
    objc_property_attribute_t backingivar = { "V", [proName cStringUsingEncoding:NSUTF8StringEncoding]};
    objc_property_attribute_t attrs[] = {type,attribute2, ownership, backingivar};
    //创建People对象p1
    id p1 = [[People alloc]init];
    
    //向People类中添加名为pro的属性,属性的4个特性包含在attributes中
    if (class_addProperty([p1 class], [proName cStringUsingEncoding:NSUTF8StringEncoding], attrs, 4)) {
        
        NSString *s = [NSString stringWithFormat:@"set%@:",[proName capitalizedString]];
        
        //添加get和set方法
        class_addMethod([p1 class], NSSelectorFromString(proName), (IMP)getter, "@@:");
        class_addMethod([p1 class], NSSelectorFromString(s), (IMP)setter, "v@:@");
    }
    
    
    objc_property_t * properties = class_copyPropertyList([p1 class], &count);
    for (int i = 0; i<count; i++) {
        NSLog(@"属性的名称为 : %s",property_getName(properties[i]));
        NSLog(@"属性的特性字符串为: %s",property_getAttributes(properties[i]));
    }
    NSString *s = [NSString stringWithFormat:@"set%@:",[proName capitalizedString]];
    
//    [p1 setValue:@"111" forKey:@"pro"];
//    NSLog(@"%@", [p1 valueForKey:@"pro"]);
    [p1 performSelector:NSSelectorFromString(s) withObject:@"111"];
    id pro = [p1 performSelector:NSSelectorFromString(@"pro")];
}

id getter(id self1, SEL _cmd1) {
    NSString *key = NSStringFromSelector(_cmd1);
    Ivar ivar = class_getInstanceVariable([self1 class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *s = object_getIvar(self1, ivar);
    return s;
}

void setter(id self1, SEL _cmd1, id newValue) {
    //移除set
    NSString *key = [NSStringFromSelector(_cmd1) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    //首字母小写
    NSString *head = [key substringWithRange:NSMakeRange(0, 1)];
    head = [head lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    //移除后缀 ":"
    key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length - 1, 1) withString:@""];
    
    Ivar ivar = class_getInstanceVariable([self1 class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
    object_setIvar(self1, ivar, newValue);
}
//
//+ (void)addStrPropertyForTargetClass:(Class)target Name:(NSString *)propertyName {
//    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([NSString class])] UTF8String] }; //type
//    objc_property_attribute_t ownership0 = { "C", "" }; // C = copy
//    objc_property_attribute_t ownership = { "N", "" }; //N = nonatomic
//    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };  //variable name
//    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
//    if (class_addProperty(target, [propertyName UTF8String], attrs, 4)) {
//            //添加get和set方法
//            class_addMethod([target class], NSSelectorFromString(propertyName), (IMP)getter, "@@:");
//            class_addMethod([target class], NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)setter, "v@:@");
//
//            //赋值
////            [target setValue:@"value" forKey:propertyName];
////            NSLog(@"%@", [target valueForKey:propertyName]);
//
//        } else {
//            class_replaceProperty([target class], [propertyName UTF8String], attrs, 3);
//            //添加get和set方法
//            class_addMethod([target class], NSSelectorFromString(propertyName), (IMP)getter, "@@:");
//            class_addMethod([target class], NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)setter, "v@:@");
//
//            //赋值
////            [target setValue:value forKey:propertyName];
//        }
//}
//
//id getter(id self1, SEL _cmd1) {
//    NSString *key = NSStringFromSelector(_cmd1);
//    Ivar ivar = class_getInstanceVariable([self1 class], [key cStringUsingEncoding:NSUTF8StringEncoding]);  //basicsViewController里面有个_dictCustomerProperty属性
//    return object_getIvar(self1, ivar);
//}
//
//void setter(id self1, SEL _cmd1, id newValue) {
//    //移除set
//    NSString *key = [NSStringFromSelector(_cmd1) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
//    //首字母小写
//    NSString *head = [key substringWithRange:NSMakeRange(0, 1)];
//    head = [head lowercaseString];
//    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
//    //移除后缀 ":"
//    key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length - 1, 1) withString:@""];
//
//    Ivar ivar = class_getInstanceVariable([self1 class],[key cStringUsingEncoding:NSUTF8StringEncoding]);
//    object_setIvar(self1, ivar, newValue);
//
//    //basicsViewController里面有个_dictCustomerProperty属性
////    NSMutableDictionary *dictCustomerProperty = object_getIvar(self1, ivar);
////    if (!dictCustomerProperty) {
////        dictCustomerProperty = [NSMutableDictionary dictionary];
////        object_setIvar(self1, ivar, dictCustomerProperty);
////    }
////    [dictCustomerProperty setObject:newValue forKey:key];
//}



+ (void)testMeta {
    NSLog(@"%s",__FUNCTION__);
}

- (void)test1 {
    //    [Instrumentation logEvent:@"view did load"];
    
    //    self.textLb.textAlignment = NSTextAlignmentNatural;
    //    SSubView *sview = [[SSubView alloc] init];
    //    Model *amodel = [[Model alloc] init];
    
    //   BOOL result = [amodel respondsToSelector:@selector(resolveThisMethodDynamically)];
    //    [sview performSelector:@selector(doSomethingElse)];
    //    [sview performSelector:@selector(resolveThisMethodDynamically)];
    //    View *view = [[View alloc] init];
    //    BOOL result1 = [SSubView isSubclassOfClass:[View class]];
    //    BOOL result2 = [View isSubclassOfClass:[View class]];
    //    NSLog(@"result1 = %d,result2 = %d",result1,result2);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    //    int b = 0;
    //    BOOL result3 = [View instancesRespondToSelector:@selector(test1)];
    //    BOOL result4 = [View instancesRespondToSelector:@selector(test2)];
    id someClass = [View new];
    
    //    BOOL result5 = [View instancesRespondToSelector:@selector(doSomethingElse)];
    //    BOOL result6 = [view respondsToSelector:@selector(doSomethingElse)];
    //    [someClass performSelector:@selector(doSomething)];
    //    [someClass performSelector:@selector(doSomethingElse)];
    //    [[[SubView alloc] init] performSelector:@selector(doSomething)];
    //     NSLog(@"someClass invocation: %s",sel_getName(((View*)someClass).invocation.selector));
    //     NSLog(@"self selector: %s",sel_getName(((View *)someClass).selector));
    //    [someClass performSelector:@selector(text)];
    //    BOOL result7 =  [View respondsToSelector:@selector(test1)];
    //    BOOL result8 =  [View respondsToSelector:@selector(test2)];
    //    BOOL result9 =  [view respondsToSelector:@selector(test1)];
    //    BOOL result10 =  [view respondsToSelector:@selector(test2)];
    //    BOOL result11 = [sview conformsToProtocol:@protocol(SomeProtocol)];
    //
    //    IMP imp11 = [view methodForSelector:@selector(test1)];
    //    IMP imp1 = [view methodForSelector:@selector(test2)];
    //    IMP imp2 = [View methodForSelector:@selector(test1)];
    //    IMP imp22 = [View methodForSelector:@selector(test2)];
    //    IMP imp3 = [View instanceMethodForSelector:@selector(test1)];
    //    IMP imp4 = [View instanceMethodForSelector:@selector(test2)];
    
    //    NSMethodSignature *signature1 = [View instanceMethodSignatureForSelector:@selector(test1)];
    //    NSMethodSignature *signature11 = [View instanceMethodSignatureForSelector:@selector(test2)];
    //
    //    View *view2 = [[View alloc] init];
    //    _weakView = view2;
    //    printf("\nretain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(view2)));
    //    id result12 = view2.autoContentAccessingProxy;
    //    [view2 beginContentAccess];
    //    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(view2)));
    //    [view2 discardContentIfPossible];
    //    [view2 beginContentAccess];
    //    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(view2)));
    //    [view2 endContentAccess];
    //     printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(view2)));
    //    [view2 endContentAccess];
    //     printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(view2)));
    //    [view2 endContentAccess];
    //     printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(view2)));
    //    NSLog(@"view2 = %@",view2);
    
#pragma clang diagnostic pop
    //    Model *model = [Model new];
    //    void(*setDelegate)(id,SEL,id<UINavigationControllerDelegate>) =(void (*)(id,SEL,id <UINavigationControllerDelegate>))[UINavigationController instanceMethodForSelector:@selector(setDelegate:)];
    //    NSLog(@"view = %@,model = %@",sview,model);
}

- (void)testNSDecimalNumber {
    //    float a = 1.454;
    //    NSLog(@"%.1f",a);
    //    NSLog(@"%.2f",a);
    //    NSLog(@"%.1f",roundf(a * 100) / 100);
    //    NSLog(@"%.2f",roundf(a * 100) / 100);
    
//    2018-06-21 15:57:30.129134+0800 TestDamo[38765:6302965] 1.  137
//    2018-06-21 15:57:30.129249+0800 TestDamo[38765:6302965] 2.  137
//    2018-06-21 15:57:30.129390+0800 TestDamo[38765:6302965] 3.  136
//    2018-06-21 15:57:30.129587+0800 TestDamo[38765:6302965] 4.  137
//    2018-06-21 15:57:30.129676+0800 TestDamo[38765:6302965] 4.2   137
//    2018-06-21 15:57:30.129849+0800 TestDamo[38765:6302965] 5.  136
//    2018-06-21 15:57:30.129930+0800 TestDamo[38765:6302965] 6.  136
//    2018-06-21 15:57:30.130052+0800 TestDamo[38765:6302965] 7.  136.6
//    2018-06-21 15:57:30.130127+0800 TestDamo[38765:6302965] 8.  136.6
//    2018-06-21 15:57:30.130358+0800 TestDamo[38765:6302965] 9.  136.5
    NSString *value = @"136.55";
    CGFloat other = 136.54689989080;
    double a = value.doubleValue;
    double b = 136.5;
    double c = 136.55;
    NSLog(@"1.  %d",(int)(value.doubleValue + 0.5));
    NSLog(@"2.  %.f",value.floatValue+0.000000000001);
    //    NSLog(@"%.f",value.floatValue);
    NSLog(@"3.  %f",roundf(value.doubleValue * 100)/100);
    NSLog(@"4.  %f",roundf(value.floatValue * 100 / 100));
    NSLog(@"4.2   %.2f",roundf(value.floatValue));
    NSLog(@"5.  %.f",roundf(b * 100) / 100);
    NSLog(@"6.  %.f",b);
    double s = (value.doubleValue - fabs(other -  round(other * 100) / 100)) / value.doubleValue;
    
    NSLog(@"7.  %.1f",round(c * 100) / 100);
    NSLog(@"8.  %.1f",136.55);
    
    NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:value];
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                       scale:1
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:YES];
    
    NSDecimalNumber *yy = [num decimalNumberByRoundingAccordingToBehavior:roundUp];
    NSLog(@"9.  %@",yy);
    
    NSLog(@"%s",__FUNCTION__);
}


- (void)testKVO {
    Model *model = [[Model alloc] init];
    _model = model;
    model.name = @"a";
    
    [model addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld |NSKeyValueObservingOptionNew context:NULL];
    [model addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionOld |NSKeyValueObservingOptionNew context:NULL];
    [model addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionOld |NSKeyValueObservingOptionNew context:NULL];
    [model addObserver:self forKeyPath:@"info" options:NSKeyValueObservingOptionOld |NSKeyValueObservingOptionNew context:NULL];
    model.name = @"b";
    NSMutableArray *array  = [model mutableArrayValueForKey:@"array"];
    [array addObject:@"c"];
    [array addObject:@"d"];
    NSLog(@"array address = %p",&array);
    NSLog(@"model address = %p",&model);
    NSLog(@"self address  =%p",&self);
    NSMutableArray *testArray = (NSMutableArray *)[NSArray array];
    if ([testArray isKindOfClass:[NSMutableArray class]])  {
        NSLog(@"can modify testArray");
    }
   [model performSelector:sel_getUid("debug")];
    
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    NSLog(@"change = %@",change);
//}

struct point{
    double x,y;
};
struct point barycentre(int n, ... )
{
    int i;
    struct point t;
    struct point sum={0};
    va_list listPointer;
    va_start(listPointer, n);
    for(i=0;i<n;i++){
        t=va_arg(listPointer,struct point);
        sum.x+=t.x;
        sum.y+=t.y;
    }
    sum.x/=n;
    sum.y/=n;
    va_end(listPointer);
    return sum;
}

- (void)testAg {
    struct point a,b,c,bc;
    a.x = 11;
    a.y = 12;
    b.x = 21;
    b.y = 22;
    c.x = 31;
    c.y = 32;
    bc = barycentre(3,a,b,c);
    printf("barycentre:(%f,%f)",bc.x,bc.y);
}

- (void)test3DTouch {
    UIApplicationShortcutItem * item = [[UIApplicationShortcutItem alloc]initWithType:@"two" localizedTitle:@"标签2" localizedSubtitle:@"222" icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeLove] userInfo:nil];
    
    // 设置自定义标签图片

    UIApplicationShortcutItem * itemTwo = [[UIApplicationShortcutItem alloc]initWithType:@"two" localizedTitle:@"标签3" localizedSubtitle:@"333" icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"2"] userInfo:nil];
    
    UIApplicationShortcutItem * itemThird = [[UIApplicationShortcutItem alloc]initWithType:@"two" localizedTitle:@"标签4" localizedSubtitle:@"444" icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch] userInfo:nil];
    
    [UIApplication sharedApplication].shortcutItems = @[item, itemTwo, itemThird];
}

- (void)testThread {
    _lock = [[NSLock alloc] init];
    [_lock lock];
//    [_lock lock];
//    [_lock unlock];
    [_lock unlock];
   NSThread *t = [self creatThreadWithTarget:self selector:@selector(testModelDecode) object:nil stackSize:20
                  *1024];
    NSLog(@"%ld",t.stackSize);
}

- (NSThread *)creatThreadWithTarget:(id)target
                           selector:(SEL)selector
                             object:(id)object
                          stackSize:(NSUInteger)size {
    if ((size % 4096) != 0) {
        return nil;
    }
    NSThread *t = [[NSThread alloc] initWithTarget:target selector:selector object:object];
    t.stackSize = 32 * 1024;
    NSLog(@"%ld",t.stackSize);
    [t start];
    return t;
}

- (void)testModelDecode {
    NSString *documentPath       = [self getDocumentPath];
    NSString *arrayFilePath      = [documentPath stringByAppendingPathComponent:@"data.plist"];
    TestModel *testModel = [[TestModel alloc] init];
    testModel.name = @"jack";
    NSLog(@"%@",testModel.classForCoder);

    NSString *attriArr = [[testModel class] description];
    BOOL result = [NSKeyedArchiver archiveRootObject:testModel toFile:arrayFilePath];
    TestModel *aModel = [NSKeyedUnarchiver unarchiveObjectWithFile:arrayFilePath];
    NSLog(@"%@",aModel.classForCoder);
    NSLog(@"%@",aModel.classForKeyedArchiver);
}

- (void)testRootViewController {
    NSLog(@"%@",[[UIApplication sharedApplication].keyWindow rootViewController]);
    [self startNetworkAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@",[[UIApplication sharedApplication].keyWindow rootViewController]);
    });
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    NSLog(@"model's name = %@",_model.name);
//}

//- (void)testRetainCycle {
//    self.model = [[Model alloc] init];
//    self.model.name = @"啊";
//    NSLog(@"viewController model address %@",self.model);
//}

- (void)buttonClick:(UIButton *)button {
    AwakeViewController *vc = [[AwakeViewController alloc] init];
//    self.cameraVC = vc;
//    vc.model = self.model;
    Class class =  NSClassFromString(@"ObserverViewController");
    if (self.navigationController.viewControllers.count >2) {
        [NSException raise:@"crash button has click" format:@""];
    }
    [self.navigationController pushViewController:vc animated:YES];
    [self removeSliderObserver];
}

- (void)removeSliderObserver {
    [_progressSlider removeObserver:self forKeyPath:@"value"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSIndexSet *set = [change valueForKey:@"indexes"];
    if (set) {
        NSInteger index = set.firstIndex;
    }
    NSLog(@"%@",change);
}

- (void)testDoesNotRecognizeSelector {
    SubView *sview = [[SubView alloc] init];
    [sview performSelector:@selector(noSelector)];
}



- (void)testPreventInherited {
    SubView *sview = [[SubView alloc] init];
    BOOL result = [sview respondsToSelector:@selector(preventInherited)];
    [sview performSelector:@selector(preventInherited)];
}

- (void)testThreadPerformSelector {
    //    [NSThread detachNewThreadWithBlock:^{
    //        NSLog(@"%@",[NSThread currentThread]);
    //        for (int i = 0; i < 100; i ++) {
    //            NSString *str = [NSString stringWithFormat:@"%d",i];
    //顺序执行
    //            [self performSelectorOnMainThread:@selector(autoContentTest:) withObject:str waitUntilDone:i % 2];
    //        }
    //    }];
   
}



//- (void)testSign {
//    Model *__strong str1 = [[Model alloc] init];
//    Model * __weak str2 = [[Model alloc] init];
//    Model * __unsafe_unretained str3 = [[Model alloc] init];
//    Model * __autoreleasing str4 = [[Model alloc] init];
//    printf("str3 retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(str4)));
//    NSLog(@"str1 : %@\n str2: %@ \n str3: %@ \n str4: %@ \n",str1,str2,str3,str4);
//}


- (void)autoContentTest:(NSString *)str {
    NSLog(@"%@",str);
}

- (void)setUpUI {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    BOOL result = [button isAccessibilityElement];
   
    [_progressSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld context:NULL];
    void *ob = _progressSlider.observationInfo;
    
    NSLog(@"%@", _progressSlider.observationInfo);
    
    _aView.accessibilityActivationPoint = CGPointMake(150, 100);
    NSLog(@"accessibilityActivationPoint = %@",NSStringFromCGPoint(_aView.accessibilityActivationPoint));
    if (@available(iOS 11.0, *)) {
        NSLog(@"accessibilityAttributedHint = %@",_aView.accessibilityAttributedHint);
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 11.0, *)) {
        NSLog(@"accessibilityAttributedLabel = %@",_aView.accessibilityAttributedLabel);
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 11.0, *)) {
        NSLog(@"accessibilityAttributedValue = %@",_aView.accessibilityAttributedValue);
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 11.0, *)) {
        NSLog(@"accessibilityContainerType = %ld",(long)_aView.accessibilityContainerType);
    } else {
        // Fallback on earlier versions
    }
    NSLog(@"accessibilityCustomActions = %@",_aView.accessibilityCustomActions);
    NSLog(@"accessibilityCustomRotors = %@",_aView.accessibilityCustomRotors);
    if (@available(iOS 11.0, *)) {
        NSLog(@"accessibilityDragSourceDescriptors = %@",_aView.accessibilityDragSourceDescriptors);
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 11.0, *)) {
        NSLog(@"accessibilityDropPointDescriptors = %@",_aView.accessibilityDropPointDescriptors);
    } else {
        // Fallback on earlier versions
    }
    NSLog(@"accessibilityElements = %@",_aView.accessibilityElements);
    NSLog(@"accessibilityElementsHidden = %d",_aView.accessibilityElementsHidden);
    NSLog(@"accessibilityHint = %@",_aView.accessibilityHint);
    NSLog(@"accessibilityLabel = %@",_aView.accessibilityLabel);
    NSLog(@"accessibilityLanguage = %@",_aView.accessibilityLanguage);
    NSLog(@"accessibilityNavigationStyle = %ld",(long)_aView.accessibilityNavigationStyle);
    NSLog(@"accessibilityPath = %@",_aView.accessibilityPath);
    NSLog(@"accessibilityTraits = %llu",_aView.accessibilityTraits);
    NSLog(@"accessibilityValue = %@",_aView.accessibilityValue);
    NSLog(@"accessibilityViewIsModal = %d",_aView.accessibilityViewIsModal);
    NSLog(@"accessibilityFrame = %@",NSStringFromCGRect(_aView.accessibilityFrame));
    
//    NSString *string = @"死垃圾法拉盛骄傲了京234d大件垃圾放辣椒;阿附近啊安静地方辣椒粉;安抚辣椒粉垃圾发阿附近啊;激发阿两地分居;埃及法";
//    NSMutableAttributedString *mAttriStr = [[NSMutableAttributedString alloc] initWithString:string];
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.alignment = NSTextAlignmentJustified;
//    paragraphStyle.paragraphSpacing = 11.0;
//    paragraphStyle.paragraphSpacingBefore = 10;
//    paragraphStyle.firstLineHeadIndent = 0.0;
//    paragraphStyle.headIndent = 0.0;
//    NSDictionary *dict = @{NSForegroundColorAttributeName : [UIColor grayColor],
//                           NSFontAttributeName: [UIFont systemFontOfSize:15],
//                           NSParagraphStyleAttributeName : paragraphStyle,
//                           NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleNone]
//                           };
//    [mAttriStr setAttributes:dict range:NSMakeRange(0, mAttriStr.length)];
//    self.textLb.attributedText = mAttriStr;
    
    NSString *title = @"2016/8/39697686868"; //@"不得不说 YYKit第三方框架确实很牛，YYLabel在富文本显示和操作方面相当强大，尤其是其异步渲染，让界面要多流畅有多流畅，这里我们介绍下简单的使用";
    
//    YYLabel 富文本
    YYLabel  *titleLabel = [YYLabel new];
    titleLabel.backgroundColor = [UIColor lightGrayColor];
    //异步渲染 当一个label显示巨量文字的时候就能明显感觉到此功能的强大
    titleLabel.displaysAsynchronously = YES;
//    [self.view addSubview:titleLabel];

    titleLabel.numberOfLines = 0;
    YYTextContainer  *titleContarer = [YYTextContainer new];

    //限制宽度
    titleContarer.size    = CGSizeMake(100,CGFLOAT_MAX);
    NSMutableAttributedString  *titleAttr = [self getAttr:title];
    titleLabel.attributedText = titleAttr;
    YYTextLayout *titleLayout = [YYTextLayout layoutWithContainer:titleContarer text:titleAttr];

    CGFloat titleLabelHeight = titleLayout.textBoundingSize.height;
    titleLabel.frame = CGRectMake(50,50,100,titleLabelHeight);
    
}

- (NSMutableAttributedString*)getAttr:(NSString*)attributedString {
    NSMutableAttributedString * resultAttr = [[NSMutableAttributedString alloc] initWithString:attributedString];
    
    //对齐方式 这里是 两边对齐
    resultAttr.alignment = NSTextAlignmentJustified;
    //设置行间距
    resultAttr.lineSpacing = 5;
    //设置字体大小
    resultAttr.font = [UIFont systemFontOfSize:16];
    //可以设置某段字体的大小
    //[resultAttr yy_setFont:[UIFont boldSystemFontOfSize:CONTENT_FONT_SIZE] range:NSMakeRange(0, 3)];
    //设置字间距
//    resultAttr.kern = [NSNumber numberWithFloat:5.0];
    
    return resultAttr;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//    [Instrumentation logEvent:@"did receive memery warning "];
}

- (void)startNetworkAnimation{
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
}

- (void)stopNetworkAnimation{
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = NO;
}

/* 获取Documents文件夹路径 */
- (NSString *)getDocumentPath {
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documents[0];
    return documentPath;
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}


@end
