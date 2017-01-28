//
//  XYProfileBaseController.m
//  
//
//  Created by mofeini on 16/9/25.
//  Copyright © 2016年 sey. All rights reserved.
//

#import "XYProfileBaseController.h"

@interface XYProfileBaseController ()

@property (nonatomic, strong) UIView *xy_topBar;     // 导航条xy_topBar
@property (nonatomic, strong) UIView *shadowLineView;        // 导航条阴影线
@property (nonatomic, strong) UIImage *xy_backBarImage;      // 导航条左侧返回按钮的图片
@property (nonatomic, assign) UIControlState xy_backBarState; // 导航条左侧返回按钮的状态
@property (nonatomic, weak) UIButton *leftButton;            // 导航条左侧按钮
@property (nonatomic, weak) UIButton *xy_titleButton;          // 导航条titleView
@property (nonatomic, copy) NSString *xy_backBarTitle;       // 导航条左侧返回按钮的文字，这个属性在当前控制器下有效
@property (nonatomic, weak) NSLayoutConstraint *xy_topBarHConst;
@end

@implementation XYProfileBaseController
static id obj;

@synthesize xy_rightButton = _xy_rightButton;
@synthesize xy_titleButton = _xy_titleButton;
@synthesize xy_title = _xy_title;
@synthesize xy_backBarTitle = _xy_backBarTitle;
@synthesize xy_backBarImage = _xy_backBarImage;
@synthesize hiddenLeftButton = _hiddenLeftButton;
@synthesize xy_titleColor = _xy_titleColor;
@synthesize xy_tintColor = _xy_tintColor;

#pragma mark - 控制器view的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCustomBar];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    obj = self;
    
    // 显示在最顶部，防止子控制器的view添加子控件时盖住了xy_topBar
    [self.view bringSubviewToFront:self.xy_topBar];
    
    // 控制model和push时左侧返回按钮的隐藏和显示
    if (self.presentedViewController) {
        if ([self.presentedViewController isKindOfClass:[UIViewController class]] && self.presentedViewController.navigationController.childViewControllers.count <= 1) {
            self.hiddenLeftButton = YES;
        } else if ([self.presentedViewController isKindOfClass:[UINavigationController class]] && self.childViewControllers.count <= 1) {
            self.hiddenLeftButton = YES;
        }
    } else if (self.presentingViewController) {
        self.hiddenLeftButton = NO;
    } else if (!self.presentedViewController && self.navigationController.childViewControllers.count <= 1) {
        self.hiddenLeftButton = YES;
    } else {
        self.hiddenLeftButton = NO;
    }
        
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    
    
    [self makeConstr];
    
}

#pragma mark - set和get方法

- (UIColor *)xy_titleColor {
    
    return _xy_titleColor ?: [UIColor blackColor];
}

- (void)setXy_titleColor:(UIColor *)xy_titleColor {
    
    _xy_titleColor = xy_titleColor;
    [self.xy_titleButton setTitleColor:xy_titleColor forState:UIControlStateNormal];
}

- (UIFont *)xy_buttonFont {
    
    return _xy_buttonFont ?: [UIFont systemFontOfSize:16];
}
- (UIColor *)xy_tintColor {
    
    return _xy_tintColor ?: [UIColor colorWithWhite:50/255.0 alpha:1.0];
}

- (void)setXy_tintColor:(UIColor *)xy_tintColor {
    
    _xy_tintColor = xy_tintColor;
    [self.leftButton setTitleColor:xy_tintColor forState:UIControlStateNormal];
    [self.xy_rightButton setTitleColor:xy_tintColor forState:UIControlStateNormal];
}

- (void)setXy_title:(NSString *)xy_title {
    
    _xy_title = xy_title;
    [self.xy_titleButton setTitle:xy_title forState:UIControlStateNormal];
    
    if (_xy_titleView) {
        [_xy_titleView removeFromSuperview];
        _xy_titleView = nil;
    }
    
}

- (NSString *)xy_title {
    
    return _xy_title ?: nil;
    
}

- (BOOL)isHiddenLeftButton {
    
    return _hiddenLeftButton ?: NO;
}

- (void)setHiddenLeftButton:(BOOL)hiddenLeftButton {
    _hiddenLeftButton = hiddenLeftButton;
    self.leftButton.hidden = hiddenLeftButton;
}

- (void)setXy_titleView:(UIView *)xy_titleView {
    
    _xy_titleView = xy_titleView;
    if (_xy_title || _xy_titleButton) {
        // 为了避免自定义的titleView与xy_titleButton产生冲突
        _xy_title = nil;
        [_xy_titleButton removeFromSuperview];
        _xy_titleButton = nil;
    }
    if (!xy_titleView.superview && ![xy_titleView.superview isEqual:self.xy_topBar]) {
        if ([xy_titleView isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)xy_titleView;
            label.textAlignment = NSTextAlignmentCenter;
        }
        [self.xy_topBar addSubview:xy_titleView];
        xy_titleView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    if ([xy_titleView isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)xy_titleView;
        imgView.contentMode = UIViewContentModeCenter;
    }
    
    
}

- (UIButton *)xy_titleButton {
    if (_xy_titleButton == nil) {
        UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.xy_topBar addSubview:titleView];
        [titleView setTitle:self.xy_title forState:UIControlStateNormal];
        [titleView setTitleColor:self.xy_titleColor forState:UIControlStateNormal];
        _xy_titleButton = titleView;
        titleView.translatesAutoresizingMaskIntoConstraints = NO;
        return _xy_titleButton;
    } else {
        [_xy_titleButton setTitleColor:self.xy_titleColor forState:UIControlStateNormal];
        return _xy_titleButton;
    }
}


- (void)setXy_titleButton:(UIButton *)xy_titleButton {
    
    _xy_titleButton = xy_titleButton;
    [xy_titleButton removeFromSuperview];
    if (!xy_titleButton.superview && ![xy_titleButton.superview isEqual:self.xy_topBar]) {
        [self.xy_topBar addSubview:xy_titleButton];
        xy_titleButton.userInteractionEnabled = NO;
        xy_titleButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

- (UIButton *)xy_rightButton {
    if (_xy_rightButton) {
        
        [_xy_rightButton setTitleColor:self.xy_tintColor forState:UIControlStateNormal];
        _xy_rightButton.titleLabel.font = self.xy_buttonFont;
    }
    return _xy_rightButton;
}

- (void)setXy_rightButton:(UIButton *)xy_rightButton {
    
    _xy_rightButton = xy_rightButton;
    [xy_rightButton removeFromSuperview];
    if (!xy_rightButton.superview && ![xy_rightButton.superview isEqual:self.xy_topBar]) {
        [self.xy_topBar addSubview:xy_rightButton];
        xy_rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
}



- (UIControlState )xy_backBarState {
    
    return _xy_backBarState ?: UIControlStateNormal;
}

- (void)setXy_backBarImage:(UIImage *)xy_backBarImage {
    
    _xy_backBarImage = xy_backBarImage;
    [self.leftButton setImage:xy_backBarImage forState:self.xy_backBarState];
}

- (void)setXy_backBarTitle:(NSString *)xy_backBarTitle {
    
    xy_backBarTitle = xy_backBarTitle;
    
    [self.leftButton setTitle:xy_backBarTitle forState:self.xy_backBarState];
}

- (NSString *)xy_backBarTitle {
    
    return _xy_backBarTitle ?: @"返回";
}
- (UIImage *)xy_backBarImage {
    
    return _xy_backBarImage ?: nil;
}

- (UIButton *)leftButton {
    
    if (_leftButton == nil) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setTitle:self.xy_backBarTitle forState:UIControlStateNormal];
        [leftButton setImage:self.xy_backBarImage forState:UIControlStateNormal];
        leftButton.titleLabel.font = self.xy_buttonFont;
        [leftButton setTitleColor:self.xy_tintColor forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [self.xy_topBar addSubview:leftButton];
        _leftButton = leftButton;
        leftButton.hidden = self.isHiddenLeftButton;
        leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _leftButton;
}


- (UIView *)xy_topBar {
    
    if (_xy_topBar == nil) {
        UIView *xy_topBar = [[UIView alloc] init];
        xy_topBar.userInteractionEnabled = YES;
        xy_topBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:xy_topBar];
        [self.view bringSubviewToFront:xy_topBar];
        _xy_topBar = xy_topBar;
    }
    return _xy_topBar;
}

- (UIView *)shadowLineView {
    
    if (_shadowLineView == nil) {
        UIView *shadowLineView = [[UIView alloc] init];
        shadowLineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.xy_topBar addSubview:shadowLineView];
        [self.xy_topBar bringSubviewToFront:shadowLineView];
        _shadowLineView = shadowLineView;
    }
    return _shadowLineView;
}

- (void)xy_setBackBarTitle:(nullable NSString *)title titleColor:(UIColor *)color image:(nullable UIImage *)image forState:(UIControlState)state {
    
    _xy_backBarTitle = title;
    _xy_backBarImage = image;
    _xy_backBarState = state;
    [self.leftButton setTitle:title forState:state];
    [self.leftButton setImage:image forState:state];
    [self.leftButton setTitleColor:color forState:state];
}

#pragma mark - 私有方法
- (void)makeConstr {
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_xy_topBar, _shadowLineView);
    NSDictionary *metrics = @{@"leftButtonMaxW": @150, @"leftButtonLeftM": @10, @"leftBtnH": @44, @"rightBtnH": @44, @"rightBtnRightM": @10};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_xy_topBar]|" options:kNilOptions metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_xy_topBar]" options:kNilOptions metrics:metrics views:views]];
    // 根据屏幕是否旋转更新xy_topBar的高度约束
    if (CGRectGetWidth([UIScreen mainScreen].bounds) > CGRectGetHeight([UIScreen mainScreen].bounds)) {
        [self.view removeConstraint:self.xy_topBarHConst];
        NSLayoutConstraint *xy_topBarHConst = [NSLayoutConstraint constraintWithItem:self.xy_topBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:44];
        [self.view addConstraint:xy_topBarHConst];
        self.xy_topBarHConst = xy_topBarHConst;
    } else {
        [self.view removeConstraint:self.xy_topBarHConst];
        NSLayoutConstraint *xy_topBarHConst = [NSLayoutConstraint constraintWithItem:self.xy_topBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:64];
        [self.view addConstraint:xy_topBarHConst];
        self.xy_topBarHConst = xy_topBarHConst;
        
    }
    
    [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shadowLineView]|" options:kNilOptions metrics:metrics views:views]];
    [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_shadowLineView(0.5)]|" options:kNilOptions metrics:metrics views:views]];
    
    if (self.leftButton && self.leftButton.superview) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_leftButton);
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftButtonLeftM-[_leftButton(<=leftButtonMaxW)]" options:kNilOptions metrics:metrics views:views]];
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftButton(leftBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    
    if (self.xy_rightButton && self.xy_rightButton.superview) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_xy_rightButton);
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_xy_rightButton(<=leftButtonMaxW)]-rightBtnRightM-|" options:kNilOptions metrics:metrics views:views]];
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_xy_rightButton(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    
    if (self.xy_titleButton && self.xy_titleButton.superview) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_xy_titleButton);
        [self.xy_topBar addConstraint:[NSLayoutConstraint constraintWithItem:self.xy_titleButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.xy_topBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.xy_topBar addConstraint:[NSLayoutConstraint constraintWithItem:self.xy_titleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:150]];
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_xy_titleButton(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    
    if (self.xy_titleView && self.xy_titleView.superview) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_xy_titleView);
        [self.xy_topBar addConstraint:[NSLayoutConstraint constraintWithItem:self.xy_titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.xy_topBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.xy_topBar addConstraint:[NSLayoutConstraint constraintWithItem:self.xy_titleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:150]];
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_xy_titleView(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
        
    }
}

- (void)setupCustomBar {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.xy_topBar.backgroundColor = [UIColor colorWithWhite:242/255.0 alpha:0.7];
    
    self.shadowLineView.backgroundColor = [UIColor colorWithWhite:160/255.0 alpha:0.7];
    
    [self.leftButton addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)leftBtnClick:(UIButton *)btn {
    
    backCompletionHandle(nil);
    
}

void backCompletionHandle(void(^callBack)()) {
   
    [obj backCompletionHandle:callBack];
}


- (void)backCompletionHandle:(nullable void(^)())block {

    if ([obj isPresent]) {
        [obj dismissViewControllerAnimated:YES completion:^{
            if (block) {
                block();
            }
        }];
    }else {
        [[obj navigationController] popViewControllerAnimated:YES];

        if (block) {
            block();
        }
    }
    
}

- (BOOL)isPresent {
    
    BOOL isPresent;
    
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self) {
            
            isPresent = NO; //push方式
        }
    }
    else{
        isPresent = YES;  // modal方式
    }
    
    return isPresent;
}


- (UIImage *)xy_imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 1.0);
    CGContextRef contexRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contexRef, [color CGColor]);
    CGContextFillRect(contexRef, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
