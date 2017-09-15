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

/** 导航条contentView */
@property (nonatomic, strong) UIView *contentView;
/** 导航条阴影线 */
@property (nonatomic, strong) UIView *shadowLineView;
/** 导航条左侧返回按钮的图片 */
@property (nonatomic, strong) UIImage *leftButtonImage;
/** 导航条左侧返回按钮的状态 */
@property (nonatomic, assign) UIControlState backBarState;
/** 导航条左侧按钮 */
@property (nonatomic, weak) UIButton *leftButton;
/** 导航条titleView */
@property (nonatomic, weak) UIButton *titleButton;
/** 导航条左侧返回按钮的文字，这个属性在当前控制器下有效 */
@property (nonatomic, copy) NSString *leftButtonTitle;
/** contentView 顶部距离父控件的间距，默认：横屏0，竖屏-20.0 */
@property (nonatomic, assign) CGFloat contentViewTopConst;
@property (nonatomic, strong) UIImageView *backgroundView;

@end

@interface UIViewController ()

@property (nonatomic) XYNavigationBar *xy_navigationBar;
@property (nonatomic) CGFloat xy_navigationBarTopConstant;

@end

@implementation UIViewController (XYNavigationBar)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeImplementationWithSelector:NSSelectorFromString(@"dealloc") swizzledSelector:@selector(xy_dealloc)];
        [self exchangeImplementationWithSelector:@selector(viewWillAppear:) swizzledSelector:@selector(xy_viewWillAppear:)];
    });
    
    
}

- (void)xy_viewWillAppear:(BOOL)animated {
    [self xy_viewWillAppear:animated];
    XYNavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(xy_navigationBar));
    if (!navigationBar) {
        return;
    }
    // 控制model和push时左侧返回按钮默认的隐藏和显示
    if (self.presentedViewController) {
        if ([self.presentedViewController isKindOfClass:[UIViewController class]] && self.presentedViewController.navigationController.childViewControllers.count <= 1) {
            navigationBar.hiddenLeftButton = YES;
        } else if ([self.presentedViewController isKindOfClass:[UINavigationController class]] && self.childViewControllers.count <= 1) {
            navigationBar.hiddenLeftButton = YES;
        }
    }
    else if (self.presentingViewController) {
        navigationBar.hiddenLeftButton = NO;
    }
    else if (!self.presentedViewController &&
             self.navigationController.childViewControllers.count <= 1) {
        navigationBar.hiddenLeftButton = YES;
    }
    else {
        navigationBar.hiddenLeftButton = NO;
    }
    
}

- (XYNavigationBar *)xy_navigationBar {
    
    XYNavigationBar *navigationBar = objc_getAssociatedObject(self, _cmd);
    if (navigationBar) {
        return navigationBar;
    }
    navigationBar = [[XYNavigationBar alloc] init];
    objc_setAssociatedObject(self, _cmd, navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superView = self.view;
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        superView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        navigationBar.alpha = 0.0;
    }
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationPortrait) {
        self.xy_navigationBarTopConstant = 20.0;
    } else {
        self.xy_navigationBarTopConstant = 0.0;
    }
    [superView addSubview:navigationBar];
    NSDictionary *subviewDict = @{@"nacBar": navigationBar};
    NSDictionary *metrics = @{@"navigationBarTop": @(self.xy_navigationBarTopConstant)};
    NSArray *contentViewConstraints = @[
                                        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==navigationBarTop)-[nacBar(>=0)]"
                                                                                options:0
                                                                                metrics:metrics
                                                                                  views:subviewDict],
                                        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nacBar]|"
                                                                                options:0
                                                                                metrics:metrics
                                                                                  views:subviewDict]
                                        ];
    
    [superView addConstraints:[contentViewConstraints valueForKeyPath:@"@unionOfArrays.self"]];
    XYNavigationBarHeight barHeight = {64.0, 44.0};
    self.xy_navigationBarHeight = barHeight;
    [self registerNotificationObserver];
    
    __weak typeof(self) selfVc = self;
    self.xy_navigationBar.leftButtonClick = ^{
        [selfVc backBtnClick];
    };
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            navigationBar.alpha = 1.0;
        } completion:NULL];
    }
    
    return navigationBar;
}

- (void)setXy_navigationBar:(XYNavigationBar *)xy_navigationBar {
    if (self.xy_navigationBar == xy_navigationBar) {
        return;
    }
    objc_setAssociatedObject(self, @selector(setXy_navigationBar:), xy_navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setXy_navigationBarHeight:(XYNavigationBarHeight)xy_navigationBarHeight {
    NSValue *heightValue = [NSValue valueWithBytes:&xy_navigationBarHeight objCType:@encode(XYNavigationBarHeight)];
    objc_setAssociatedObject(self, @selector(xy_navigationBarHeight), heightValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self xy_willChangeStatusBarOrientationNotification];
}

- (XYNavigationBarHeight)xy_navigationBarHeight {
    XYNavigationBarHeight height;
    NSValue *heightValue = objc_getAssociatedObject(self, _cmd);
    [heightValue getValue:&height];
    return height;
}

- (BOOL)registerNotificationObserver {
    BOOL flag = [objc_getAssociatedObject(self, _cmd) boolValue];
    if (!flag) {
        flag = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xy_willChangeStatusBarOrientationNotification) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        
        objc_setAssociatedObject(self, _cmd, @(flag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return flag;
}

- (void)xy_dealloc {
    XYNavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(xy_navigationBar));
    if (!navigationBar) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.xy_navigationBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.xy_navigationBar removeFromSuperview];
        [self setXy_navigationBar:nil];
    }];
}

- (void)xy_willChangeStatusBarOrientationNotification {
    XYNavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(xy_navigationBar));
    if (!navigationBar) {
        return;
    }
    CGFloat navigationBarHeight = 0.0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationPortrait) {
        navigationBarHeight = self.xy_navigationBarHeight.portraitOrientationHeight;
        navigationBar.contentViewTopConst = -20.0;
        self.xy_navigationBarTopConstant = 20.0;
    } else {
        navigationBarHeight = self.xy_navigationBarHeight.otherOrientationHeight;
        navigationBar.contentViewTopConst = 0.0;
        self.xy_navigationBarTopConstant = 0.0;
    }
    
    // 修改navigationBar的高度
    NSInteger foundIndex = [navigationBar.constraints indexOfObjectPassingTest:^BOOL(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:@"topBarConstraintHeight"];
    }];
    
    if (foundIndex != NSNotFound) {
        NSLayoutConstraint *constraint = [self.xy_navigationBar.constraints objectAtIndex:foundIndex];
        constraint.constant = navigationBarHeight;
        
    }
    else {
        
        NSLayoutConstraint *contentViewHConst = [NSLayoutConstraint constraintWithItem:navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:kNilOptions multiplier:1.0 constant:navigationBarHeight];
        contentViewHConst.identifier = @"topBarConstraintHeight";
        [self.xy_navigationBar addConstraint:contentViewHConst];
    }
    
    // 修改navigationBar的top
    NSInteger foundNavigationTopConstraintIndex = [navigationBar.superview.constraints indexOfObjectPassingTest:^BOOL(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [obj.firstItem isEqual:navigationBar] && obj.firstAttribute == NSLayoutAttributeTop;
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    if (foundNavigationTopConstraintIndex != NSNotFound) {
        NSLayoutConstraint *constraint = [navigationBar.superview.constraints objectAtIndex:foundNavigationTopConstraintIndex];
        constraint.constant = self.xy_navigationBarTopConstant;
    }
}

- (BOOL)isPresent {
    
    BOOL isPresent;
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    
    if (viewcontrollers.count > 1 && [viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self) {
        isPresent = NO;  // push
    }
    else {
        isPresent = YES; // modal
    }
    
    return isPresent;
}

- (void)backBtnClick {
    if ([self isPresent]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[self  navigationController] popViewControllerAnimated:YES];
    }
}

#pragma mark - Swizzling
+ (void)exchangeImplementationWithSelector:(SEL)originSelector swizzledSelector:(SEL)swizzledSelector {
    Class class = [self class];
    Method originMethod = class_getInstanceMethod(class, originSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originMethod),
                            method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}

#pragma mark -

- (CGFloat)xy_navigationBarTopConstant {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];;
}

- (void)setXy_navigationBarTopConstant:(CGFloat)xy_navigationBarTopConstant {
    objc_setAssociatedObject(self, @selector(xy_navigationBarTopConstant), @(xy_navigationBarTopConstant), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation XYNavigationBar


@synthesize rightButton = _rightButton;
@synthesize title = _title;
@synthesize leftButtonTitle = _leftButtonTitle;
@synthesize leftButtonImage = _leftButtonImage;
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

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.backgroundView.image = [[self class] xy_imageFromColor:backgroundColor];
}

- (void)setContentViewTopConst:(CGFloat)contentViewTopConst {
    _contentViewTopConst = contentViewTopConst;
    if (!self.constraints.count) {
        return;
    }
    NSPredicate *contentViewTopPredicate = [NSPredicate predicateWithFormat:@"identifier == %@", @"XYNavigationBarContentViewTopConstraint"];
    NSLayoutConstraint *contentViewTopConstraint = [self.constraints filteredArrayUsingPredicate:contentViewTopPredicate].firstObject;
    contentViewTopConstraint.constant = contentViewTopConst;
    
    NSPredicate *backgroundTopPredicate = [NSPredicate predicateWithFormat:@"identifier == %@", @"XYNavigationBarBackgroundTopConstraint"];
    NSLayoutConstraint *backgroundTopConstraint = [self.constraints filteredArrayUsingPredicate:backgroundTopPredicate].firstObject;
    backgroundTopConstraint.constant = contentViewTopConst;
}

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
}

- (NSString *)title {
    
    return _title ?: nil;
}


- (void)setHiddenLeftButton:(BOOL)hiddenLeftButton {
    _hiddenLeftButton = hiddenLeftButton;
    self.leftButton.hidden = hiddenLeftButton;
}

- (BOOL)isHiddenLeftButton {
    return _leftButton.isHidden;
}

- (void)setTitleView:(UIView *)titleView {
    
    if ([_titleView isEqual:titleView]) {
        return;
    }
    NSParameterAssert(!titleView.superview);
    _titleView = titleView;
    if (_titleButton && ![_titleButton isEqual:_titleView]) {
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
    
    if ([titleView isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)titleView;
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    
}

- (UIButton *)titleButton {
    if (_titleButton == nil) {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton = titleButton;
        self.titleView = titleButton;
    }
    return _titleButton;
}



- (UIButton *)rightButton {
    if (_rightButton) {
        
        [_rightButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        _rightButton.titleLabel.font = self.buttonFont;
    }
    return _rightButton;
}

- (void)setRightButton:(UIButton *)rightButton {
    if (_rightButton == rightButton) {
        return;
    }
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

- (void)setLeftButtonImage:(UIImage *)leftButtonImage {
    if (_leftButtonImage == leftButtonImage) {
        return;
    }
    _leftButtonImage = leftButtonImage;
    [self.leftButton setImage:_leftButtonImage forState:self.backBarState];
}

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle {
    
    _leftButtonTitle = leftButtonTitle;
    
    [self.leftButton setTitle:leftButtonTitle forState:self.backBarState];
}

- (NSString *)leftButtonTitle {
    
    return _leftButtonTitle ?: @"返回";
}
- (UIImage *)leftButtonImage {
    
    return _leftButtonImage ?: nil;
}

- (UIButton *)leftButton {
    
    if (_leftButton == nil) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setTitle:self.leftButtonTitle forState:UIControlStateNormal];
        [leftButton setImage:self.leftButtonImage forState:UIControlStateNormal];
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
        contentView.backgroundColor = [UIColor clearColor];
        contentView.userInteractionEnabled = YES;
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.backgroundView addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UIView *)shadowLineView {
    
    if (_shadowLineView == nil) {
        UIView *shadowLineView = [[UIView alloc] init];
        shadowLineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:shadowLineView];
        _shadowLineView = shadowLineView;
    }
    return _shadowLineView;
}

- (UIImageView *)backgroundView {
    if (_backgroundView == nil) {
        UIImageView *backgroundView = [[UIImageView alloc] init];
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:backgroundView];
        _backgroundView = backgroundView;
        _backgroundView.image = [[self class] xy_imageFromColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        backgroundView.userInteractionEnabled = YES;
    }
    return _backgroundView;
}

- (void)setLeftButtonTitle:(nullable NSString *)title image:(nullable UIImage *)image forState:(UIControlState)state {
    
    _leftButtonTitle = title;
    _leftButtonImage = image;
    _backBarState = state;
    [self.leftButton setTitle:title forState:state];
    [self.leftButton setImage:image forState:state];
}

- (void)setShadowLineHeight:(CGFloat)shadowLineHeight {
    if (_shadowLineHeight == shadowLineHeight) {
        return;
    }
    _shadowLineHeight = shadowLineHeight;
    if ([self canShowShadowLineView]) {
        NSInteger foundIndex = [self.shadowLineView.constraints indexOfObjectPassingTest:^BOOL(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.identifier isEqualToString:@"shadowLineHeight"];
        }];
        
        if (foundIndex != NSNotFound) {
            NSLayoutConstraint *constraint = [self.shadowLineView.constraints objectAtIndex:foundIndex];
            constraint.constant = shadowLineHeight;
            
        }
    }
    else {
        [_shadowLineView removeFromSuperview];
        _shadowLineView = nil;
    }
}


#pragma mark - Private (auto layout)

- (void)updateConstraints {
    
    for (NSLayoutConstraint *constr in self.constraints.copy ) {
        if (![constr.firstItem isEqual:self]) {
            [self removeConstraint:constr];
        }
    }
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.backgroundView removeConstraints:self.backgroundView.constraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_contentView, _shadowLineView, _backgroundView);
    NSDictionary *metrics = @{@"leftButtonWidth": @(self.leftButton.intrinsicContentSize.width+10), @"leftButtonLeftM": @10, @"leftBtnH": @44, @"rightBtnH": @44, @"rightBtnRightM": @10, @"rightButtonWidth": @(self.rightButton.intrinsicContentSize.width+10), @"shadowLineHeight": @(self.shadowLineHeight), @"contentViewTopConst": @(self.contentViewTopConst)};
    
    NSLayoutConstraint *backgroundTopConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.contentViewTopConst];
    backgroundTopConstraint.identifier = @"XYNavigationBarBackgroundTopConstraint";
    // backgroundView
    NSArray *backgroundViewConstraints = @[
                                           [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_backgroundView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:views],
                                           [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:views],
                                           @[backgroundTopConstraint],
                                           ];
    
    [self addConstraints:[backgroundViewConstraints valueForKeyPath:@"@unionOfArrays.self"]];
    
    // contentView
    NSLayoutConstraint *contentViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.contentViewTopConst];
    contentViewTopConstraint.identifier = @"XYNavigationBarContentViewTopConstraint";
    NSArray *contentViewConstraints = @[
                                        [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views],
                                        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views],
                                        @[contentViewTopConstraint],
                                        ];
    
    [self addConstraints:[contentViewConstraints valueForKeyPath:@"@unionOfArrays.self"]];
    
    // other
    if ([self canShowShadowLineView]) {
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shadowLineView]|" options:kNilOptions metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_shadowLineView]|" options:kNilOptions metrics:metrics views:views]];
        NSLayoutConstraint *shadowLineConstrainHeight = [NSLayoutConstraint constraintWithItem:self.shadowLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.shadowLineHeight];
        shadowLineConstrainHeight.identifier = @"shadowLineHeight";
        [self.shadowLineView addConstraint:shadowLineConstrainHeight];
    }
    else {
        [_shadowLineView removeFromSuperview];
        _shadowLineView = nil;
    }
    
    if ([self canShowLeftButton]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_leftButton);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftButtonLeftM-[_leftButton(==leftButtonWidth)]" options:kNilOptions metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftButton(leftBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    else {
        [_leftButton removeFromSuperview];
        _leftButton = nil;
    }
    
    if ([self canshowRightButton]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_rightButton);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightButton(==rightButtonWidth)]-rightBtnRightM-|" options:kNilOptions metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightButton(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    else {
        [_rightButton removeFromSuperview];
        _rightButton = nil;
    }
    
    if ([self canShowTitleView]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleView);
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleView(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
        if ([self canShowLeftButton] && !self.isHiddenLeftButton) {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.leftButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0]];
        }
        else {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        }
        if ([self canshowRightButton]) {
            NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.rightButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-0.0];
            [self.contentView addConstraint:c];
        }
        else {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        }
        
    }
    else {
        [_titleView removeFromSuperview];
        _titleView = nil;
    }
    
    [super updateConstraints];
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

- (BOOL)canShowShadowLineView {
    if (_shadowLineView.superview) {
        return YES;
    }
    return NO;
}

- (BOOL)canShowTitleView {
    if ([_titleView isEqual:_titleButton]) {
        return [self canShowTitleButton];
    }
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
    self.shadowLineView.backgroundColor = [UIColor colorWithWhite:160/255.0 alpha:0.7];
    [self.leftButton addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _hiddenLeftButton = NO;
    self.shadowLineHeight = 0.5;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationPortrait) {
        self.contentViewTopConst = -20.0;
    } else {
        self.contentViewTopConst = 0.0;
    }
    
}

- (void)leftBtnClick:(UIButton *)btn {
    if (self.leftButtonClick) {
        self.leftButtonClick();
    }
    
}

- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    UIResponder *responder = self.nextResponder;
    do {
        responder = responder.nextResponder;
    } while (responder && ![responder isKindOfClass:[UIViewController class]]);
    
    if (responder) {
        UIViewController *vc = (UIViewController *)responder;
        if (vc.navigationController && !vc.navigationController.isNavigationBarHidden) {
            vc.navigationController.navigationBar.hidden = YES;
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *touchView = [super hitTest:point withEvent:event];
    
    return touchView;
}

#pragma mark - Other
+ (UIImage *)xy_imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end


