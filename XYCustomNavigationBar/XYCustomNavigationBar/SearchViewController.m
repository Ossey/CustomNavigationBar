//
//  SearchViewController.m
//  AirbnbDemo
//
//  Created by Swae on 17/09/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "SearchViewController.h"
#import "UIViewController+XYCustomNavigationBar.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.xy_navigationBar.xy_navigationBarHeight = (XYNavigationBarHeight){44.0, 34.0};
    [self.xy_navigationBar setLeftButtonTitle:nil image:[UIImage imageNamed:@"navigation-bar-leading-button-icon-close"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XYThemeable


@end
