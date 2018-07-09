//
//  TestDamoUITests.m
//  TestDamoUITests
//
//  Created by Damo on 2018/7/2.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TestDamoUITests : XCTestCase

@end

@implementation TestDamoUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"AwakeView"].buttons[@"Back"] tap];
    /*@START_MENU_TOKEN@*/[[app.webViews childrenMatchingType:XCUIElementTypeOther].element pressForDuration:0.5];/*[["[","app.webViews childrenMatchingType:XCUIElementTypeOther].element"," tap];"," pressForDuration:0.5];"],[[[0,1,1]],[[0,3],[0,2]]],[0,0]]@END_MENU_TOKEN@*/
    
    XCUIElement *element = [[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"View"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element;
    [element tap];
    [element tap];
            
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
