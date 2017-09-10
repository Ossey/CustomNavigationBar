//
//  XYProfileBaseController.m
//  
//  Created by mofeini on 16/9/25.
//  Copyright © 2016年 sey. All rights reserved.
//

#import "XYProfileBaseController.h"

@interface XYProfileBaseController ()

@property (nonatomic, weak) NSLayoutConstraint *xy_topBarHConst;

@end

@implementation XYProfileBaseController


#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}


// 当前控制器是否正在显示
- (BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController {
    return (viewController.isViewLoaded && viewController.view.window);
}


- (void)dealloc {
    
    NSLog(@"%s", __FUNCTION__);
}

@end
