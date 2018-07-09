//
//  UIImage+Processor.m
//  TestDamo
//
//  Created by Damo on 2018/2/27.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "UIImage+Processor.h"
#define kPrecision 10

@implementation ImageDataModel

//+ (instancetype)modelWithX:(int)x Y:(int)y avrg:(float)avrg {
//    ImageDataModel *model = [ia]
//}

@end

@implementation UIImage (Processor)

/**
 二值化
 */
- (UIImage *)covertToGrayScale{
    
    CGSize size =[self size];
    int width =size.width;
    int height =size.height;
    
    //像素将画在这个数组
    uint32_t *pixels = (uint32_t *)malloc(width *height *sizeof(uint32_t));
    //清空像素数组
    memset(pixels, 0, width*height*sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //用 pixels 创建一个 context
    CGContextRef context =CGBitmapContextCreate(pixels, width, height, 8, width*sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    int tt =1;
    CGFloat intensity;
    int bw;
    
    for (int y = 0; y <height; y++) {
        for (int x =0; x <width; x ++) {
            uint8_t *rgbaPixel = (uint8_t *)&pixels[y*width+x];
            intensity = (rgbaPixel[tt] + rgbaPixel[tt + 1] + rgbaPixel[tt + 2]) / 3. / 255.;
            
            bw = intensity > 0.45?255:0;
            
            rgbaPixel[tt] = bw;
            rgbaPixel[tt + 1] = bw;
            rgbaPixel[tt + 2] = bw;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

- (NSArray<NSArray *> *)getRGBData {
    NSMutableArray *marray = [NSMutableArray array];
    CGSize size =[self size];
    int width =size.width;
    int height =size.height;
    
    //像素将画在这个数组
    uint32_t *pixels = (uint32_t *)malloc(width *height *sizeof(uint32_t));
    //清空像素数组
    memset(pixels, 0, width*height*sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //用 pixels 创建一个 context
    CGContextRef context =CGBitmapContextCreate(pixels, width, height, 8, width*sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    int tt =1;
    CGFloat intensity;
    
    @autoreleasepool {
        for (int y = 0; y <height; y++) {
            NSMutableArray *mmarray = [NSMutableArray array];
            for (int x =0; x <width; x ++) {
                @autoreleasepool {
                    uint8_t *rgbaPixel = (uint8_t *)&pixels[y*width+x];
                    intensity = (rgbaPixel[tt] + rgbaPixel[tt + 1] + rgbaPixel[tt + 2]) / 3. / 255.;
                    if (x % 3 == 0) {
                        [mmarray addObject:[NSNumber numberWithFloat:intensity]];
                    }
                }
            }
            [marray addObject:mmarray.copy];
        }
    }
    return marray.copy;
}

- (BOOL)hasQRCode {
    NSArray <NSArray *> *dataArray  = [self getRGBData];
    if (!dataArray ||
        dataArray.count < kPrecision ||
        dataArray.firstObject.count < kPrecision) return NO;
    
    NSLog(@"start date:%@",[NSDate date]);
    @autoreleasepool {
        for (int y = 0; y < dataArray.count - kPrecision; y ++ ) {
            for (int x = 0; x < dataArray[y].count - kPrecision;x++) {
                @autoreleasepool {
                    float num = ((NSNumber *)dataArray[y][x]).floatValue;
                    if (num > 0 && num < 1) break;
                    
                    BOOL result = NO;
                    int count = 0;
                    for (int i = 0;i < kPrecision; i++) {
                        @autoreleasepool {
                            for (int j = 0; j < kPrecision; j ++) {
                                float num = ((NSNumber *)dataArray[y+i][x+i]).floatValue;
                                if (num >0 && num <1) result = YES;
                                if (num == 1) count++;
                            }
                            if (result) break;
                        }
                    }
                    
                    if (!result) {
                        return YES;
                    }
                    count = 0;
                }
            }
        }
        NSLog(@"end date:%@",[NSDate date]);
    }
    
    return NO;
}

/**
 转化灰度
 */
- (UIImage *)grayImage{
    
    int width = self.size.width;
    int height = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  kCGImageAlphaNone);
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), self.CGImage);
    
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    
    return grayImage;
}



@end


