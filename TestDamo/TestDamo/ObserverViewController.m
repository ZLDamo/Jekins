//
//  ObserverViewController.m
//  TestDamo
//
//  Created by Damo on 2018/3/29.
//  Copyright © 2018年 Damo. All rights reserved.
//

#import "ObserverViewController.h"
#import "ObserverManager.h"
#import "ObserverHander.h"


@interface ObserverViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) ObserverHander *handle;
@property (nonatomic, strong) NSString *name;
@end

@implementation ObserverViewController {
    NSTimer *_timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _textField.delegate = self;
    __weak typeof(self)weakSelf = self;
//    [self.textField addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
//    [self.textField addTarget:self action:@selector(myNameAction:) forControlEvents:(UIControlEventEditingChanged)];
    self.handle = [ObserverManager addNonRetainObserverToObserject:self keypath:@"name" block:^(NSDictionary *change) {
        NSLog(@"%@",[change valueForKey:NSKeyValueChangeNewKey]);
    }];
    self.textView.text = @"lalaldema";
    _name = [NSString stringWithFormat:@"sfs"];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES
//                                               block:^(NSTimer * _Nonnull timer) {
//                                                   static int count = 0;
//                                                   weakSelf.label.text = [NSString stringWithFormat:@"%d",count];
//                                                   count++;
//                                                   NSLog(@"%@",weakSelf.handle.observer?:@"");
                                                   
//                                                   UIDevice *device =  [UIDevice currentDevice];
//                                                   device.batteryMonitoringEnabled = YES;
//                                                   NSLog(@"state = %ld,level = %f",(long)device.batteryState,device.batteryLevel);
//                                               }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
//    [self.textField removeObserver:self forKeyPath:@"text"];
    NSLog(@"%s",__FUNCTION__);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"observ%@",self.textField.text);
    self.textView.text = self.textField.text;
}

- (void)myNameAction:(id)obj {
    NSLog(@"target %@",self.textField.text);
    self.textView.text = self.textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
