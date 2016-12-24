//
//  XYNextViewController.m
//  XYCustomNavigationBar
//
//  Created by mofeini on 16/12/23.
//  Copyright © 2016年 com.test.demo. All rights reserved.
//

#import "XYNextViewController.h"

@interface XYNextViewController ()

@end

@implementation XYNextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:@"title_image"];
    self.xy_customTitleView = imgView;
    
    [self xy_setBackBarTitle:nil titleColor:nil image:[UIImage imageNamed:@"ChannelCategory_back"] forState:UIControlStateNormal];
}
- (IBAction)backBtnClick:(id)sender {
    
    [self backCompletionHandle:^{
        [[[UIAlertView alloc] initWithTitle:@"退出啦" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
