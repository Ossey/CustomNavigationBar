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
    
    [self setupCustomBar];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 显示在最顶部，防止子控制器的view添加子控件时盖住了xy_topBar
    [self.view bringSubviewToFront:self.xy_navigationBar];
    
    // 控制model和push时左侧返回按钮的隐藏和显示
    if (self.presentedViewController) {
        if ([self.presentedViewController isKindOfClass:[UIViewController class]] && self.presentedViewController.navigationController.childViewControllers.count <= 1) {
            self.xy_navigationBar.hiddenLeftButton = YES;
        } else if ([self.presentedViewController isKindOfClass:[UINavigationController class]] && self.childViewControllers.count <= 1) {
            self.xy_navigationBar.hiddenLeftButton = YES;
        }
    } else if (self.presentingViewController) {
        self.xy_navigationBar.hiddenLeftButton = NO;
    } else if (!self.presentedViewController && self.navigationController.childViewControllers.count <= 1) {
        self.xy_navigationBar.hiddenLeftButton = YES;
    } else {
        self.xy_navigationBar.hiddenLeftButton = NO;
    }
    
    
}



- (void)setupCustomBar {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}






// 判断当前控制器是否正在显示
- (BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController
{
    return (viewController.isViewLoaded && viewController.view.window);
}


- (void)dealloc {
    
    NSLog(@"%s", __FUNCTION__);
}

@end
