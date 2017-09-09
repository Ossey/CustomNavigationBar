//
//  XYProfileBaseController.m
//  
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
    
    __weak typeof(self) weakSelf = self;
    self.xy_navigationBar.backCompletionHandle = ^{
        if ([weakSelf isPresent]) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }else {
            [[weakSelf  navigationController] popViewControllerAnimated:YES];
        }
        
    };
}

- (void)setupCustomBar {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

- (XYNavigationBar *)xy_navigationBar {
    if (!_xy_navigationBar) {
        _xy_navigationBar = [[XYNavigationBar alloc] init];
        _xy_navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_xy_navigationBar];
        NSDictionary *subviewDict = @{@"nacBar": _xy_navigationBar};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nacBar]|" options:kNilOptions metrics:nil views:subviewDict]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nacBar]" options:kNilOptions metrics:nil views:subviewDict]];
    }
    return _xy_navigationBar;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (CGRectGetWidth([UIScreen mainScreen].bounds) > CGRectGetHeight([UIScreen mainScreen].bounds)) {
        [self.view removeConstraint:self.xy_topBarHConst];
        NSLayoutConstraint *xy_topBarHConst = [NSLayoutConstraint constraintWithItem:self.xy_navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:44];
        [self.view addConstraint:xy_topBarHConst];
        self.xy_topBarHConst = xy_topBarHConst;
    } else {
        [self.view removeConstraint:self.xy_topBarHConst];
        NSLayoutConstraint *xy_topBarHConst = [NSLayoutConstraint constraintWithItem:self.xy_navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:64];
        [self.view addConstraint:xy_topBarHConst];
        self.xy_topBarHConst = xy_topBarHConst;
        
    }
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    [self.view setNeedsUpdateConstraints];
    
}






- (BOOL)isPresent {
    
    BOOL isPresent;
    
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    
    if (viewcontrollers.count > 1 && [viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self) {
            isPresent = NO; //push方式
    }
    else{
        isPresent = YES;  // modal方式
    }
    
    return isPresent;
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
