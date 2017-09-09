//
//  ViewController.m
//  XYCustomNavigationBar
//
//  Created by mofeini on 16/12/23.
//  Copyright © 2016年 com.test.demo. All rights reserved.
//

#import "ViewController.h"
#import "Test1ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.xy_navigationBar.xy_topBar.backgroundColor = [UIColor colorWithRed:57/255.0 green:217/255.0 blue:146/255.0 alpha:0.8];
    
    self.xy_navigationBar.xy_title = @"自定义的导航条";
    self.xy_navigationBar.xy_titleColor = [UIColor whiteColor];
    
    // 设置右侧按钮
    self.xy_navigationBar.xy_rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.xy_navigationBar.xy_rightButton setTitle:@"右侧" forState:UIControlStateNormal];
    [self.xy_navigationBar.xy_rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchDown];
    
    UIButton *modalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [modalBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:modalBtn];
    [modalBtn setTitle:@"modal" forState:UIControlStateNormal];
    modalBtn.frame = CGRectMake(100, 300, 300, 44);
    [modalBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pushBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    Test1ViewController *nextVc = [Test1ViewController new];
    nextVc.view.backgroundColor = [UIColor whiteColor];
    nextVc.xy_navigationBar.xy_topBar.backgroundColor = [UIColor colorWithRed:57/255.0 green:217/255.0 blue:146/255.0 alpha:0.8];
    
    nextVc.xy_navigationBar.xy_title = @"自定义的导航条";
    nextVc.xy_navigationBar.xy_titleColor = [UIColor whiteColor];
    [self showDetailViewController:nextVc sender:self];
}

- (void)pushClick {
    
    Test1ViewController *nextVc = [Test1ViewController new];
    nextVc.view.backgroundColor = [UIColor whiteColor];
    nextVc.xy_navigationBar.xy_topBar.backgroundColor = [UIColor colorWithRed:57/255.0 green:217/255.0 blue:146/255.0 alpha:0.8];
    
    nextVc.xy_navigationBar.xy_title = @"自定义的导航条";
    nextVc.xy_navigationBar.xy_titleColor = [UIColor whiteColor];
    [self.navigationController pushViewController:nextVc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}


@end
