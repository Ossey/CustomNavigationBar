//
//  ViewController.m
//  XYCustomNavigationBar
//
//  Created by mofeini on 16/12/23.
//  Copyright © 2016年 com.test.demo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){

    UIImageView *_imageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topBackgroundView.backgroundColor = [UIColor colorWithRed:57/255.0 green:217/255.0 blue:146/255.0 alpha:0.8];
    
    self.xy_title = @"自定义的导航条";
    self.xy_titleColor = [UIColor whiteColor];
    // 设置右侧按钮
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitle:@"右侧" forState:UIControlStateNormal];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.topBackgroundView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    _imageView.image = [UIImage imageNamed:@"1"];
    [self.view insertSubview:_imageView atIndex:0];
}

- (IBAction)btnClick:(id)sender {
    
    // model弹出
    ViewController *vc = [ViewController new];
    vc.view.backgroundColor = [UIColor colorWithWhite:38/255.0 alpha:0.8];
    vc.xy_titleColor = [UIColor blackColor];
    vc.xy_title = @"Model的";
    vc.topBackgroundView.backgroundColor = [UIColor colorWithWhite:240/255.0 alpha:0.5];
    XYProfileNavigationController *nav = [[XYProfileNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}


@end
