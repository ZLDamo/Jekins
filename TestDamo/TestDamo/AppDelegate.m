//
//  AppDelegate.m
//  TestDamo
//
//  Created by Damo on 2018/1/26.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "AppDelegate.h"
#import <Flurry.h>
#import "ViewController.h"
#import "Instrumentation.h"
#import <CocoaLumberjack.h>
#import "CameraViewController.h"

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelError;
#endif

@interface AppDelegate ()

@property(strong, nonatomic)NSTimer *mTimer;
@property(assign, nonatomic)UIBackgroundTaskIdentifier backIden;

@end

@implementation AppDelegate {
    NSInteger count;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
//     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
//    navigationController.navigationBar.translucent = false;
//    self.window.rootViewController = navigationController;
    
//    [Flurry logAllPageViewsForTarget:navigationController];
//    [Flurry startSession:@"JZB8P6XXHG9MZM6ZJJ9P"];
    //    [Flurry setAge:21];
    //    [Flurry logError:@"ERROR_NAME" message:@"ERROR_MESSAGE" exception:nil];
    
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    //你的日志语句将被发送到Console.app
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    // 添加DDFileLogger，你的日志语句将写入到一个文件中，默认路径在沙盒的Library/Caches/Logs/目录下，文件名为bundleid+空格+日期.log。
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    //产生Log
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogInfo(@"Info");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _mTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_mTimer forMode:NSRunLoopCommonModes];
    [self beginTask];
    
    [Instrumentation logEvent:@"did enter background"];

}

//计时
-(void)countAction{
    NSLog(@"%li",count++);
}

//申请后台
-(void)beginTask
{
    NSLog(@"begin=============");
    _backIden = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        //在时间到之前会进入这个block，一般是iOS7及以上是3分钟。按照规范，在这里要手动结束后台，你不写也是会结束的（据说会crash）
        NSLog(@"将要挂起=============");
        [self endBack];
    }];
}

//注销后台
-(void)endBack
{
    NSLog(@"end=============");
    [[UIApplication sharedApplication] endBackgroundTask:_backIden];
    _backIden = UIBackgroundTaskInvalid;
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"进入前台");
    [self endBack];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [Instrumentation logEvent:@"become active"];
    //捕捉结束时间
//    [Flurry endTimedEvent:@"become active" withParameters:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler{
    
    //判断先前我们设置的唯一标识
    
    if([shortcutItem.localizedTitle isEqualToString:@"标签1"]){
        
        NSArray *arr = @[@"hello 3D Touch"];
        
        UIActivityViewController *vc = [[UIActivityViewController alloc]initWithActivityItems:arr applicationActivities:nil];
        
        //设置当前的VC 为rootVC
        
        [self.window.rootViewController presentViewController:vc animated:YES completion:^{
            
        }];
        
    }
    
    if ([shortcutItem.localizedTitle isEqual: @"标签2"]) {
        
        // 点击标签2时，显示提示框
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"OPPS!" message:@"啦啦啦" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alert = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alert];
        
        [self.window.rootViewController presentViewController:alertC animated:YES completion:^{
            
        }];
        
        return;
        
    }
    
}



@end
