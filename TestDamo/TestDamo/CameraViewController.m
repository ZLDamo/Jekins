//
//  CameraViewController.m
//  TestDamo
//
//  Created by Damo on 2018/2/27.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "CameraViewController.h"
#import "UIImage+Processor.h"
#import <AVFoundation/AVFoundation.h>
#import "Model.h"

//设备宽/高/坐标
#define APPDELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
#define KDeviceFrame [UIScreen mainScreen].bounds

#define KSCREENRATE ((float)[UIScreen mainScreen].bounds.size.width / 375.0)
#define KSCREENHEIGHTRATE ((float)[UIScreen mainScreen].bounds.size.height / 667.0)

#define H(x) (x * KSCREENRATE)
#define V(y) (y * KSCREENHEIGHTRATE)

// 底部tabbar的高度设置为49
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
//注意：请直接获取系统的tabbar高度，若没有用系统tabbar，建议判断屏幕高度；之前判断状态栏高度的方法不妥，如果正在通话状态栏会变高，导致判断异常，下面只是一个例子，请勿直接使用！
#define kTabBarHeight (APPDELEGATE.tabBarController.tabBar.frame.size.height)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)
#define kLineMinY (H(75) + kTopHeight)
#define kLineMaxY (H(355) + kTopHeight)
//static const float kReaderViewWidth = 200;
//static const float kReaderViewHeight = 200;

#define kReaderViewWidth H(280.f)
#define kReaderViewHeight H(280.f)


@interface CameraViewController () <AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak)  UIImageView *iv;
@property (nonatomic,   weak) UILabel *resultLb;

@property (nonatomic, strong) AVCaptureSession *qrSession;//回话
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;//读取
@property (nonatomic, strong) UIImageView *line;//交互线
//@property (nonatomic, strong) NSTimer *lineTimer;//交互线控制
@property (nonatomic, strong)NSString* stringCode;
@property (nonatomic, strong)UIButton* flashlight;   //闪光灯
@property (nonatomic, strong)UIButton* Library;     //相册
@property (nonatomic,getter=isOpenFlash)BOOL isOpenFlash;   //是否打开闪光灯
@property (nonatomic,strong)UIImageView* imgFlash;
@property(strong,nonatomic)NSString* deviceId;
@property (nonatomic, strong) NSTimer *testTimer;
@property (nonatomic, strong) Model *model;

@end

@implementation CameraViewController {
     NSTimer *_timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.model = [[Model alloc] init];
    _imgFlash = [[UIImageView alloc] init];
    self.model.imgView = _imgFlash;
//    [self initUI];
//    [self addCamera];
//    [self setOverlayPickerView];
//    [self addFunc];
//    [self testImageProcessor];
    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));

//    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(testTimerCircle) userInfo:nil repeats:YES];
    __weak typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(weakSelf)));
//        [weakSelf.testTimer invalidate];
//        weakSelf.testTimer = nil;
//         printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(weakSelf)));
//    });
//    [self testRetainCycle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    finishedRequest = NO;
//    [self checkCamera];
//        [self.qrSession startRunning];
    //    [self getCurrentImgToCheck];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self save];
//    });
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

//- (void)testRetainCycle {
//    NSLog(@"CameraVC model address %@",self.model);
//    self.model = [[Model alloc] init];
//    self.model.name = @"d";
//    [self.model testRetainCycle:self];
//    NSLog(@"CameraVC model address %@",self.model);
//}

- (void)testTimerCircle {
//     printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
}

- (void)addCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES; //可编辑
    //判断是否可以打开照相机
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        //摄像头
//        //UIImagePickerControllerSourceTypeSavedPhotosAlbum:相机胶卷
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    } else { //否则打开照片库
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    if ([mediaType isEqualToString:@"public.image"]) {
        //得到照片
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self checkQR:image];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
    

-(void)save{

    UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size); //currentView 当前的view

    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);  //保存到相册中

}

- (void)testImageProcessor {
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0.png"]];
    _iv = iv;
    iv.frame = CGRectMake(250, 550, 100, 100);
    [self.view addSubview:iv];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, 80, 30)];
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"二值化" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(binaryButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(150, 30, 80, 30)];
    button2.backgroundColor = UIColor.greenColor;
    [button2 setTitle:@"灰度化" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(binaryButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(250, 30, 80, 30)];
    button3.backgroundColor = UIColor.blueColor;
    [button3 setTitle:@"切换" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(recoverButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 500, 80, 30)];
    label.text = @"否";
    label.textColor = [UIColor redColor];
    self.resultLb = label;
    [self.view addSubview:label];
    
    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(200, 500, 150, 30)];
    button4.backgroundColor = UIColor.grayColor;
    [button4 setTitle:@"是否包含二维码" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(checkButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
}

- (void)binaryButtonClick  {
    _iv.image = [_iv.image covertToGrayScale];
}

- (void)grayButtonClick {
    _iv.image = [_iv.image grayImage];
}

- (void)checkButtonClick {
//    [self.qrSession startRunning];
    [self addCamera];
}

- (void)checkQR:(UIImage *)image {
    self.resultLb.text = @"正在检查";
    NSArray *array = [image getRGBData];
//    UIImage *img = _iv.image;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL result = [image hasQRCode];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.resultLb.text = result ? @"是" : @"否";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getCurrentImgToCheck];
            });
        });
    });
}

- (void)getCurrentImgToCheck {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *img = [self imageFromView:self.view atFrame:CGRectMake(52.44,146.8,309.12,309.12)];
        _iv.image = img;
        [self checkQR:img];
        
    });
}

- (void)recoverButtonClick {
    static int count = 1;
//    _iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",count % 5 + 1]];
    _iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"5.JPG"]];
    count ++;
}

-(void)checkCamera{
    //摄像头判断
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError* error = nil;
    //    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私-相机”选项中，允许飞科智能访问你的相机" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            
            //            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            //
            //            if([[UIApplication sharedApplication] canOpenURL:url]) {
            //
            //                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
            //
            //            }
            //
            //            [alert dismissViewControllerAnimated:YES completion:nil];
            
            
        }];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        
        return;
    }
}

- (void)initUI
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError* error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私-相机”选项中，允许飞科智能访问你的相机" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
            
            //            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            //
            //            if([[UIApplication sharedApplication] canOpenURL:url]) {
            //
            //                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
            //
            //            }
            //
            //            [self.navigationController popToRootViewControllerAnimated:YES];
            //
            
        }];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        
        return;
    }
    
    //设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置输出的代理
    //使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];
    
    //拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // 读取质量，质量越高，可读取小尺寸的二维码
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else
    {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    
    //设置输出的格式
    //一定要先设置会话的输出为output之后，再指定输出的元数据类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置预览图层
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    //设置preview图层的属性
    //preview.borderColor = [UIColor redColor].CGColor;
    //preview.borderWidth = 1.5;
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //设置preview图层的大小
    preview.frame = self.view.layer.bounds;
    //[preview setFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight)];
    
    //将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    //[self.view.layer addSublayer:preview];
    self.qrVideoPreviewLayer = preview;
    self.qrSession = session;
}

- (void)setOverlayPickerView
{
    //画中间的基准线
    _line = [[UIImageView alloc] initWithFrame:CGRectMake((kDeviceWidth - kReaderViewWidth) / 2.0, kLineMinY, kReaderViewWidth, 2)];
    [_line setImage:[UIImage imageNamed:@"ff_QRCodeScanLine"]];
    [self.view addSubview:_line];
    
    //最上部view
    //    if (iPhone4) {
    //        kLineMinY = 80;
    //        kLineMaxY = 280;
    //    }
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kLineMinY)];//80
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMinY, (kDeviceWidth - kReaderViewWidth) / 2.0, kReaderViewHeight)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(kDeviceWidth - CGRectGetMaxX(leftView.frame), kLineMinY, CGRectGetMaxX(leftView.frame), kReaderViewHeight)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    CGFloat space_h = KDeviceHeight - kLineMaxY;
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMaxY, kDeviceWidth, space_h)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    
    //四个边角
    UIImage *cornerImage = [UIImage imageNamed:@"ScanQR1"];
    
    //左侧的view
    UIImageView *leftView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    leftView_image.image = cornerImage;
    [self.view addSubview:leftView_image];
    
    cornerImage = [UIImage imageNamed:@"ScanQR2"];
    
    //右侧的view
    UIImageView *rightView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    rightView_image.image = cornerImage;
    [self.view addSubview:rightView_image];
    
    cornerImage = [UIImage imageNamed:@"SCanQR3"];
    
    //底部view
    UIImageView *downView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downView_image.image = cornerImage;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView_image];
    
    cornerImage = [UIImage imageNamed:@"ScanQR4"];
    
    UIImageView *downViewRight_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downViewRight_image.image = cornerImage;
    //downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downViewRight_image];
    
    //说明label
    UILabel *labIntroudction = [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame = CGRectMake(CGRectGetMaxX(leftView.frame) - H(10), CGRectGetMinY(downView.frame) + H(70), kReaderViewWidth + H(20), H(15));
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont systemFontOfSize:15.0];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.text = @"将二维码放入框内，即可自动扫描";
    [self.view addSubview:labIntroudction];
    
    UIImageView *scanCropView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"扫一扫边框"]];
    
    scanCropView.frame = CGRectMake(CGRectGetMaxX(leftView.frame),kLineMinY ,kReaderViewWidth, kReaderViewHeight);
    //    scanCropView.layer.borderColor = [UIColor greenColor].CGColor;
    //    scanCropView.layer.borderWidth = 2.0;
    [self.view addSubview:scanCropView];
}

-(void)Flashlight{
    if (self.isOpenFlash) {
        [self turnTorchOn:false];
        self.isOpenFlash = false;
        self.imgFlash.image = [UIImage imageNamed:@"闪光灯"];
        [self.flashlight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [self turnTorchOn:true];
        self.isOpenFlash = true;
//        [self.flashlight setTitleColor:Color_Bg_Line forState:UIControlStateNormal];
        self.imgFlash.image = [UIImage imageNamed:@"闪光灯开启"];
        
    }
}

-(void)addFunc{
    CGRect rect = CGRectMake(0, self.view.bounds.size.height - H(60) - 0 + 49, self.view.bounds.size.width, H(60));
    UIView* view = [[UIView alloc] initWithFrame:rect];
    view.tintColor = [UIColor clearColor];
    [view setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:view];
    
    self.Library = [[UIButton alloc]initWithFrame:CGRectMake(H(66), H(6), H(60), H(80))];
    self.Library.titleLabel.font = [UIFont systemFontOfSize:10.f];
    [self.Library setTitle:@"相册" forState:UIControlStateNormal];
    
    UIImage* photo = [UIImage imageNamed:@"icon_photo"];
    UIImageView* viewPhoto = [[UIImageView alloc]initWithFrame:CGRectMake(H(82), H(6), H(28), H(28))];
    viewPhoto.image = photo;
    
    UIImageView* viewFlash = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - H(110) , H(6), H(28), H(28))];
    self.imgFlash = viewFlash;
    viewFlash.image = [UIImage imageNamed:@"闪光灯"];
    
    self.flashlight = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - H(126), H(6), H(60), H(80))];
    [self.flashlight setTitle:@"闪光灯" forState:UIControlStateNormal];
    self.flashlight.titleLabel.font = [UIFont systemFontOfSize:10.f];
    
    
    [view addSubview:viewFlash];
    [view addSubview:viewPhoto];
    [view addSubview:self.flashlight];
    [view addSubview:self.Library];
    
    [self.Library addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self.flashlight addTarget:self action:@selector(Flashlight) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 摄像头
- (void) turnTorchOn: (bool) on {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //                torchIsOn = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //                torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize
{
    NSLog(@"%f",kLineMinY);
    NSLog(@"%f",KDeviceHeight);
    
    NSLog(@"%f", kLineMinY / KDeviceHeight);
    CGRect size = CGRectMake(kLineMinY / KDeviceHeight, ((kDeviceWidth - asize.width) / 2.0) / kDeviceWidth, asize.height / KDeviceHeight, asize.width / kDeviceWidth);
    return size;
}


//此方法是在识别到QRCode，并且完成转换
//如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描结果
    if (metadataObjects.count > 0)
    {
//        [self.qrSession stopRunning];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0)
        {
            NSRange range = [obj.stringValue rangeOfString:@"#"];
            if (range.length!=0) {
                NSArray* result = [obj.stringValue componentsSeparatedByString:@"#"];
                self.stringCode = result[1];
            }else{
                self.stringCode = obj.stringValue;
            }
            
//            NSLog(@"___Scan BarCode = %@", self.stringCode);
            //检验二维码是否已经被绑定
//            NSLog(@"code = %@",self.stringCode);
        }
        else
        {

        }
    }
    else
    {

    }
}


//获得某个范围内的屏幕图像
- (UIImage *)imageFromView:(UIView *)theView   atFrame:(CGRect)r
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(r);
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:r];
}

@end
