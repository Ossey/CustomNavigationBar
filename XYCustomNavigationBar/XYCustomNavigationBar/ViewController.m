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
    
    self.xy_navigationBar.backgroundColor = [UIColor colorWithRed:57/255.0 green:217/255.0 blue:146/255.0 alpha:0.8];
    
    self.xy_navigationBar.title = @"自定义的导航条";
    self.xy_navigationBar.titleColor = [UIColor whiteColor];
    
    // 设置右侧按钮
    self.xy_navigationBar.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.xy_navigationBar.rightButton setTitle:@"右侧" forState:UIControlStateNormal];
    [self.xy_navigationBar.rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchDown];
    
    [self setXy_navigationBarHeight:(XYNavigationBarHeight){100.0, 64.0}];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)rightButtonClick {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"知道了" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)modalBtnClick:(id)sender {
    Test1ViewController *nextVc = [Test1ViewController new];
    nextVc.view.backgroundColor = [UIColor whiteColor];
    nextVc.xy_navigationBar.backgroundColor = [UIColor colorWithRed:57/255.0 green:217/255.0 blue:146/255.0 alpha:0.8];
    
    nextVc.xy_navigationBar.title = @"自定义的导航条";
    [self.xy_navigationBar setLeftButtonTitle:@"back" image:nil forState:UIControlStateNormal];
    nextVc.xy_navigationBar.titleColor = [UIColor whiteColor];
    [self showDetailViewController:nextVc sender:self];
    nextVc.xy_navigationBar.shadowLineHeight = 0.0;
}

- (IBAction)pushClick:(id)sender {
    
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    Test1ViewController *nextVc = [nextStoryboard instantiateViewControllerWithIdentifier:@"test1"];
    nextVc.view.backgroundColor = [UIColor whiteColor];
    nextVc.xy_navigationBar.backgroundColor = [UIColor colorWithRed:57/255.0 green:217/255.0 blue:146/255.0 alpha:0.8];
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setTitle:@"XYNavigationBarController_neeeueueuueu" forState:UIControlStateNormal];
    nextVc.xy_navigationBar.titleView = titleButton;
    [self.navigationController pushViewController:nextVc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}



@end
