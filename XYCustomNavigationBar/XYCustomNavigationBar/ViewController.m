//
//  ViewController.m
//  XYCustomNavigationBar
//
//  Created by mofeini on 16/12/23.
//  Copyright © 2016年 com.test.demo. All rights reserved.
//

#import "ViewController.h"
#import "XYTwoViewController.h"
#import "XYNextViewController.h"

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
    [self.rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchDown];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.topBackgroundView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    _imageView.image = [UIImage imageNamed:@"1"];
    [self.view addSubview:_imageView];
    
    UIButton *modalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:modalBtn];
    [modalBtn setTitle:@"modal" forState:UIControlStateNormal];
    modalBtn.frame = CGRectMake(100, 300, 300, 44);
    [modalBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:pushBtn];
    [pushBtn setTitle:@"push" forState:UIControlStateNormal];
    pushBtn.frame = CGRectMake(100, 400, 300, 44);
    [pushBtn addTarget:self action:@selector(pushClick) forControlEvents:UIControlEventTouchDown];

}


- (void)rightButtonClick {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"知道了" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)btnClick:(id)sender {
    
    XYTwoViewController *vc = [XYTwoViewController new];
    XYProfileNavigationController *nav = [[XYProfileNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)pushClick {
    
    XYNextViewController *nextVc = [XYNextViewController new];
    [self.navigationController pushViewController:nextVc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}


@end
