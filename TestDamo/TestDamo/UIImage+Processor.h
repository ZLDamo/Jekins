//
//  UIImage+Processor.h
//  TestDamo
//
//  Created by Damo on 2018/2/27.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Processor)

- (UIImage *)covertToGrayScale;
- (UIImage *)grayImage;
- (NSArray<NSArray *> *)getRGBData;
- (BOOL)hasQRCode;
- (UIImage *)imageFromView:(UIView *)theView   atFrame:(CGRect)r;

@end


@interface ImageDataModel : NSObject

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) float RGBAvrg;

@end
