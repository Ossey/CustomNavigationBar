//
//  XYTwoViewController.m
//  XYCustomNavigationBar
//
//  Created by mofeini on 16/12/24.
//  Copyright © 2016年 com.test.demo. All rights reserved.
//

#import "XYTwoViewController.h"
#import "XYNextViewController.h"

@interface XYTwoViewController ()

@end

@implementation XYTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.xy_titleColor = [UIColor blackColor];
    self.xy_title = @"标题";
    self.xy_tintColor = [UIColor whiteColor];
    self.xy_titleColor = [UIColor whiteColor];
    self.shadowLineView.backgroundColor = [UIColor clearColor];
    self.topBackgroundView.backgroundColor = [UIColor colorWithWhite:80/255.0 alpha:0.5];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(200, 200, 200, 40);
    [btn setTitle:@"跳转" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(jumpToNext) forControlEvents:UIControlEventTouchDown];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:back];
    back.frame = CGRectMake(100, 300, 200, 40);
    [back setTitle:@"back" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchDown];

}

- (void)backClick {
    
    [self backCompletionHandle:^{
        [[[UIAlertView alloc] initWithTitle:@"退出啦" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
    }];
}


- (void)jumpToNext {
    
    XYNextViewController *next = [XYNextViewController new];
    
    [self.navigationController pushViewController:next animated:YES];
}



@end
