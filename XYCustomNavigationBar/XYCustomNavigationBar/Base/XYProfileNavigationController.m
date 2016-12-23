//
//  XYNavigationController.m
//  
//
//  Created by mofeini on 16/9/25.
//  Copyright © 2016年 sey. All rights reserved.
//

#import "XYProfileNavigationController.h"
#import "XYProfileBaseController.h"

@interface XYProfileNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation XYProfileNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarHidden:YES];

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
        viewController.hidesBottomBarWhenPushed = self.childViewControllers.count > 0;
    }
    [super pushViewController:viewController animated:animated];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    return self.viewControllers.count > 1;
}


- (void)dealloc {
    
    NSLog(@"%s", __FUNCTION__);
}


@end



