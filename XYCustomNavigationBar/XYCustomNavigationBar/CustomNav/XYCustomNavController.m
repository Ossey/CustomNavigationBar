//
//  XYCustomNavController.m
//  
//
//  Created by mofeini on 16/9/25.
//  Copyright © 2016年 sey. All rights reserved.
//

#import "XYCustomNavController.h"
#import "XYProfileBaseController.h"

@interface XYCustomNavController () <UIGestureRecognizerDelegate>

@end

@implementation XYCustomNavController

+ (void)initialize {
    if (self == [XYCustomNavController class]) {
        UINavigationBar *bar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[self]];
        [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [bar setShadowImage:[UIImage new]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    [self setNavigationBarHidden:YES];
    
    // 全屏滑动返回手势
    id target = self.interactivePopGestureRecognizer.delegate;
    self.interactivePopGestureRecognizer.enabled = NO;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    
    [self.view addGestureRecognizer:pan];
    
    pan.delegate = self;
   
    self.interactivePopGestureRecognizer.enabled = NO;
}

- (void)pushViewController:(XYProfileBaseController *)viewController animated:(BOOL)animated {

    if ([viewController isKindOfClass:[XYProfileBaseController class]]) {
        if (viewController.isHiddenLeftButton) {
            
            viewController.hiddenLeftButton = self.childViewControllers.count < 1;
        }
        if (self.childViewControllers.count) {
            viewController.hidesBottomBarWhenPushed = YES;
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:viewController action:@selector(leftBtnClick:)];
        }
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark - <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    return self.viewControllers.count > 1;
}


- (void)dealloc {
    
    NSLog(@"%s", __FUNCTION__);
}

// 为了不上上面的代码报警告
- (void)leftBtnClick:(UIBarButtonItem *)item {
    
}

// 为了让上面的代码不报警告
- (void)handleNavigationTransition:(UIPanGestureRecognizer *)pan {

}

@end



