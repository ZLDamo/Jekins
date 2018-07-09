//
//  TestProtocol.h
//  TestDamo
//
//  Created by Damo on 2018/7/6.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TestProtocol <NSObject>
@required
@property (nonatomic, strong) NSString *name;


@required
- (void)getProtocolName;

@end
