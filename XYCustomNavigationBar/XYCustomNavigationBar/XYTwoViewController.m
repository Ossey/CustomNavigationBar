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
    self.xy_title = @"Model的";
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
}

- (void)jumpToNext {
    
    XYNextViewController *next = [XYNextViewController new];
    
    [self.navigationController pushViewController:next animated:YES];
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
