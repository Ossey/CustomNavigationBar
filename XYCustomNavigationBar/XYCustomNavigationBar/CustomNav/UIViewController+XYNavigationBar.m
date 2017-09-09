//
//  UIViewController+XYNavigationBar.m
//  XYCustomNavigationBar
//
//  Created by Swae on 10/09/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "UIViewController+XYNavigationBar.h"
#import <objc/runtime.h>


@interface XYNavigationBar ()

@property (nonatomic, strong) UIView *contentView;             // 导航条contentView
@property (nonatomic, strong) UIView *shadowLineView;        // 导航条阴影线
@property (nonatomic, strong) UIImage *backBarImage;      // 导航条左侧返回按钮的图片
@property (nonatomic, assign) UIControlState backBarState; // 导航条左侧返回按钮的状态
@property (nonatomic, weak) UIButton *leftButton;            // 导航条左侧按钮
@property (nonatomic, weak) UIButton *titleButton;          // 导航条titleView
@property (nonatomic, copy) NSString *backBarTitle;       // 导航条左侧返回按钮的文字，这个属性在当前控制器下有效


@end


@implementation UIViewController (XYNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc")),
                                       class_getInstanceMethod(self.class, @selector(xy_dealloc)));
    });
    
    
}

- (XYNavigationBar *)xy_navigationBar {
    
    NSUInteger foundIndex = [self.view.subviews indexOfObjectPassingTest:^BOOL(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [subview isKindOfClass:[XYNavigationBar class]];
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    
    if (foundIndex != NSNotFound) {
        return self.view.subviews[foundIndex];
    }
    
    XYNavigationBar *navigationBar = [[XYNavigationBar alloc] init];
    navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:navigationBar];
    NSDictionary *subviewDict = @{@"nacBar": navigationBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nacBar]|" options:kNilOptions metrics:nil views:subviewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nacBar]" options:kNilOptions metrics:nil views:subviewDict]];
    [self xy_willChangeStatusBarOrientationNotification];
    [self registerNotification];
    
    __weak typeof(self) selfVc = self;
    self.xy_navigationBar.backCompletionHandle = ^{
        [selfVc backBtnClick];
    };
    

    return navigationBar;
}

- (BOOL)registerNotification {
    BOOL flag = [objc_getAssociatedObject(self, _cmd) boolValue];
    if (!flag) {
        flag = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xy_willChangeStatusBarOrientationNotification) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        
        objc_setAssociatedObject(self, _cmd, @(flag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return flag;
}

- (void)xy_dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}


- (void)xy_willChangeStatusBarOrientationNotification {
    CGFloat navigationBarHeight = 0.0;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        navigationBarHeight = 44;
    }
    else {
        navigationBarHeight = 64;
    }
    
    NSInteger foundIndex = [self.view.constraints indexOfObjectPassingTest:^BOOL(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:@"topBarConstraintHeight"];
    }];
    
    if (foundIndex != NSNotFound) {
        NSLayoutConstraint *constraint = [self.view.constraints objectAtIndex:foundIndex];
        constraint.constant = navigationBarHeight;
        
    }
    else {
        
        NSLayoutConstraint *contentViewHConst = [NSLayoutConstraint constraintWithItem:self.xy_navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:navigationBarHeight];
        contentViewHConst.identifier = @"topBarConstraintHeight";
        [self.view addConstraint:contentViewHConst];
    }
    
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

- (void)backBtnClick {
    if ([self isPresent]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [[self  navigationController] popViewControllerAnimated:YES];
    }
}

@end

@implementation XYNavigationBar


@synthesize rightButton = _rightButton;
@synthesize titleButton = _titleButton;
@synthesize title = _title;
@synthesize backBarTitle = _backBarTitle;
@synthesize backBarImage = _backBarImage;
@synthesize hiddenLeftButton = _hiddenLeftButton;
@synthesize titleColor = _titleColor;
@synthesize tintColor = _tintColor;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCustomBar];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupCustomBar];
    }
    return self;
}

#pragma mark - Set \ Get

- (UIColor *)titleColor {
    
    return _titleColor ?: [UIColor blackColor];
}

- (void)setTitleColor:(UIColor *)titleColor {
    
    _titleColor = titleColor;
    [self.titleButton setTitleColor:titleColor forState:UIControlStateNormal];
}

- (UIFont *)buttonFont {
    
    return _buttonFont ?: [UIFont systemFontOfSize:16];
}
- (UIColor *)tintColor {
    
    return _tintColor ?: [UIColor colorWithWhite:50/255.0 alpha:1.0];
}

- (void)setTintColor:(UIColor *)tintColor {
    
    _tintColor = tintColor;
    [self.leftButton setTitleColor:tintColor forState:UIControlStateNormal];
    [self.rightButton setTitleColor:tintColor forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title {
    
    _title = title;
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    
    if (_titleView) {
        [_titleView removeFromSuperview];
        _titleView = nil;
    }
    
}

- (NSString *)title {
    
    return _title ?: nil;
    
}


- (void)setHiddenLeftButton:(BOOL)hiddenLeftButton {
    _hiddenLeftButton = hiddenLeftButton;
    self.leftButton.hidden = hiddenLeftButton;
}

- (void)setTitleView:(UIView *)titleView {
    
    _titleView = titleView;
    if (_title || _titleButton) {
        // 为了避免自定义的titleView与titleButton产生冲突
        _title = nil;
        [_titleButton removeFromSuperview];
        _titleButton = nil;
    }
    if (!titleView.superview && ![titleView.superview isEqual:self.contentView]) {
        if ([titleView isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)titleView;
            label.textAlignment = NSTextAlignmentCenter;
        }
        [self.contentView addSubview:titleView];
        titleView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    if ([titleView isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)titleView;
        imgView.contentMode = UIViewContentModeCenter;
    }
    
    
}

- (UIButton *)titleButton {
    if (_titleButton == nil) {
        UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:titleView];
        [titleView setTitle:self.title forState:UIControlStateNormal];
        [titleView setTitleColor:self.titleColor forState:UIControlStateNormal];
        _titleButton = titleView;
        titleView.translatesAutoresizingMaskIntoConstraints = NO;
        return _titleButton;
    } else {
        [_titleButton setTitleColor:self.titleColor forState:UIControlStateNormal];
        return _titleButton;
    }
}


- (void)setTitleButton:(UIButton *)titleButton {
    
    _titleButton = titleButton;
    [titleButton removeFromSuperview];
    if (!titleButton.superview && ![titleButton.superview isEqual:self.contentView]) {
        [self.contentView addSubview:titleButton];
        titleButton.userInteractionEnabled = NO;
        titleButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

- (UIButton *)rightButton {
    if (_rightButton) {
        
        [_rightButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        _rightButton.titleLabel.font = self.buttonFont;
    }
    return _rightButton;
}

- (void)setRightButton:(UIButton *)rightButton {
    
    _rightButton = rightButton;
    [rightButton removeFromSuperview];
    if (!rightButton.superview && ![rightButton.superview isEqual:self.contentView]) {
        [self.contentView addSubview:rightButton];
        rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
}



- (UIControlState )backBarState {
    
    return _backBarState ?: UIControlStateNormal;
}

- (void)setBackBarImage:(UIImage *)backBarImage {
    
    _backBarImage = backBarImage;
    [self.leftButton setImage:backBarImage forState:self.backBarState];
}

- (void)setBackBarTitle:(NSString *)backBarTitle {
    
    backBarTitle = backBarTitle;
    
    [self.leftButton setTitle:backBarTitle forState:self.backBarState];
}

- (NSString *)backBarTitle {
    
    return _backBarTitle ?: @"返回";
}
- (UIImage *)backBarImage {
    
    return _backBarImage ?: nil;
}

- (UIButton *)leftButton {
    
    if (_leftButton == nil) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setTitle:self.backBarTitle forState:UIControlStateNormal];
        [leftButton setImage:self.backBarImage forState:UIControlStateNormal];
        leftButton.titleLabel.font = self.buttonFont;
        [leftButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [self.contentView addSubview:leftButton];
        _leftButton = leftButton;
        leftButton.hidden = self.isHiddenLeftButton;
        leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _leftButton;
}


- (UIView *)contentView {
    
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        contentView.userInteractionEnabled = YES;
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentView];
        [self bringSubviewToFront:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UIView *)shadowLineView {
    
    if (_shadowLineView == nil) {
        UIView *shadowLineView = [[UIView alloc] init];
        shadowLineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:shadowLineView];
        [self.contentView bringSubviewToFront:shadowLineView];
        _shadowLineView = shadowLineView;
    }
    return _shadowLineView;
}

- (void)setBackBarTitle:(nullable NSString *)title titleColor:(UIColor *)color image:(nullable UIImage *)image forState:(UIControlState)state {
    
    _backBarTitle = title;
    _backBarImage = image;
    _backBarState = state;
    [self.leftButton setTitle:title forState:state];
    [self.leftButton setImage:image forState:state];
    [self.leftButton setTitleColor:color forState:state];
}


#pragma mark - Private (auto layout)
- (void)updateConstraints {
    [super updateConstraints];
    
    [self removeConstraints:self.constraints];
    [self.contentView removeConstraints:self.contentView.constraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_contentView, _shadowLineView);
    NSDictionary *metrics = @{@"leftButtonMaxW": @150, @"leftButtonLeftM": @10, @"leftBtnH": @44, @"rightBtnH": @44, @"rightBtnRightM": @10};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:kNilOptions metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:kNilOptions metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shadowLineView]|" options:kNilOptions metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_shadowLineView(0.5)]|" options:kNilOptions metrics:metrics views:views]];
    
    if ([self canShowLeftButton]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_leftButton);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftButtonLeftM-[_leftButton(<=leftButtonMaxW)]" options:kNilOptions metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftButton(leftBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    else {
        [_leftButton removeFromSuperview];
        _leftButton = nil;
    }
    
    if ([self canshowRightButton]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_rightButton);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightButton(<=leftButtonMaxW)]-rightBtnRightM-|" options:kNilOptions metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightButton(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    else {
        [_rightButton removeFromSuperview];
        _rightButton = nil;
    }
    
    if ([self canShowTitleButton]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleButton);
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:150]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleButton(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    else {
        [_titleButton removeFromSuperview];
        _titleButton = nil;
    }
    
    if ([self canShowTitleView]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleView);
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:150]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleView(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
        
    }
    else {
        [_titleView removeFromSuperview];
        _titleView = nil;
    }
}
- (BOOL)canShowLeftButton {
    if ([_leftButton titleForState:UIControlStateNormal] ||
        [_leftButton attributedTitleForState:UIControlStateNormal].string.length > 0 ||
        [_leftButton imageForState:UIControlStateNormal]) {
        return _leftButton.superview != nil;
    }
    return NO;
}

- (BOOL)canShowTitleButton {
    if ([_titleButton titleForState:UIControlStateNormal] ||
        [_titleButton attributedTitleForState:UIControlStateNormal].string.length > 0 ||
        [_titleButton imageForState:UIControlStateNormal]) {
        return _titleButton.superview != nil;
    }
    return NO;
}

- (BOOL)canShowTitleView {
    if (_titleView.superview) {
        return YES;
    }
    return NO;
}

- (BOOL)canshowRightButton {
    if ([_rightButton titleForState:UIControlStateNormal] ||
        [_rightButton attributedTitleForState:UIControlStateNormal].string.length > 0 ||
        [_rightButton imageForState:UIControlStateNormal]) {
        return _rightButton.superview != nil;
    }
    return NO;
}

- (void)setupCustomBar {
    
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor colorWithWhite:242/255.0 alpha:0.7];
    
    self.shadowLineView.backgroundColor = [UIColor colorWithWhite:160/255.0 alpha:0.7];
    
    [self.leftButton addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _hiddenLeftButton = NO;
}

- (void)leftBtnClick:(UIButton *)btn {
    if (self.backCompletionHandle) {
        self.backCompletionHandle();
    }
    
}

- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    UIResponder *responder = self.nextResponder;
    do {
        responder = responder.nextResponder;
    } while (![responder isKindOfClass:[UIViewController class]]);
    
    if (responder) {
        UIViewController *vc = (UIViewController *)responder;
        if (vc.navigationController && !vc.navigationController.isNavigationBarHidden) {
//                        vc.navigationController.navigationBar.userInteractionEnabled = NO;
//            [vc.navigationController setNavigationBarHidden:YES]; 
            vc.navigationController.navigationBar.hidden = YES;
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *touchView = [super hitTest:point withEvent:event];
    
    return touchView;
}

@end


