//
//  UIViewController+XYCustomNavigationBar.m
//  XYCustomNavigationBar
//
//  Created by Swae on 10/09/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "UIViewController+XYCustomNavigationBar.h"
#import <objc/runtime.h>

@interface NSObject (XYSwizzlingExtension)

+ (void)exchangeImplementationWithSelector:(SEL)originSelector swizzledSelector:(SEL)swizzledSelector;

@end

@interface UIView (XYNavigationBarExtension)

@property BOOL onceInstanceContentOffsetOrContentInset;

@end

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
@property (nonatomic, assign) CGFloat backgroundViewTopConstant;
@property (nonatomic, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UIVisualEffectView *visualEffectView;

@property (nonatomic) CGFloat xy_navigationBarTopConstant;

@property (nonatomic, copy) void (^xy_willChangeStatusBarOrientationBlock)(void);

- (instancetype)initWithView:(UIView *)view;

- (void)resetSubviews;
@end

@interface UIViewController ()

@property (nonatomic) XYNavigationBar *xy_navigationBar;

@end

@implementation UIViewController (XYCustomNavigationBar)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeImplementationWithSelector:NSSelectorFromString(@"dealloc") swizzledSelector:@selector(xy_dealloc)];
        [self exchangeImplementationWithSelector:@selector(viewWillAppear:) swizzledSelector:@selector(xy_viewWillAppear:)];
        [self exchangeImplementationWithSelector:@selector(automaticallyAdjustsScrollViewInsets) swizzledSelector:@selector(xy_automaticallyAdjustsScrollViewInsets)];
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
        if ([self.presentedViewController isKindOfClass:[UIViewController class]]) {
            if (self.presentedViewController.navigationController && self.presentedViewController.navigationController.childViewControllers.count <= 1) {
                navigationBar.hiddenLeftButton = YES;
            }
            else {
                navigationBar.hiddenLeftButton = self.navigationController.childViewControllers.count <= 1;
            }
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

- (BOOL)xy_automaticallyAdjustsScrollViewInsets {
    BOOL res = [self xy_automaticallyAdjustsScrollViewInsets];
    XYNavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(xy_navigationBar));
    if (!navigationBar) {
        return res;
    }
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat UIEdgeInsetsTop = 0.0, contentOffsetY = 0.0;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            if (res) {
                if (orientation == UIDeviceOrientationPortrait) {
                    UIEdgeInsetsTop = self.xy_navigationBar.xy_navigationBarHeight.portraitOrientationHeight;
                } else {
                    UIEdgeInsetsTop = self.xy_navigationBar.xy_navigationBarHeight.otherOrientationHeight;
                }
                contentOffsetY = -UIEdgeInsetsTop - 20.0;
            }
            else {
                UIEdgeInsetsTop = 0.0;
            }
            if (!scrollView.onceInstanceContentOffsetOrContentInset) {
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, contentOffsetY);
                scrollView.contentInset = UIEdgeInsetsMake(UIEdgeInsetsTop, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
                scrollView.onceInstanceContentOffsetOrContentInset = YES;
            }
        }
    }
    return res;
}

- (void)xy_willChangeStatusBarOrientation {
    
    XYNavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(xy_navigationBar));
    if (!navigationBar) {
        return;
    }
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            scrollView.onceInstanceContentOffsetOrContentInset = NO;
        }
    }
    
    [self xy_automaticallyAdjustsScrollViewInsets];
}

- (XYNavigationBar *)xy_navigationBar {
    
    XYNavigationBar *navigationBar = objc_getAssociatedObject(self, _cmd);
    if (navigationBar) {
        return navigationBar;
    }
    navigationBar = [[XYNavigationBar alloc] initWithView:self.view];
    navigationBar.backgroundColor = [UIColor clearColor];
    objc_setAssociatedObject(self, _cmd, navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    __weak typeof(self) selfVc = self;
    navigationBar.leftButtonClick = ^{
        [selfVc backBtnClick];
    };
    
    navigationBar.xy_willChangeStatusBarOrientationBlock = ^{
        [selfVc xy_willChangeStatusBarOrientation];
    };
    
    return navigationBar;
}

- (void)setXy_navigationBar:(XYNavigationBar *)xy_navigationBar {
    if (self.xy_navigationBar == xy_navigationBar) {
        return;
    }
    objc_setAssociatedObject(self, @selector(setXy_navigationBar:), xy_navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)xy_dealloc {
    XYNavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(xy_navigationBar));
    if (!navigationBar) {
        return;
    }
    [navigationBar removeFromSuperview];
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

- (instancetype)initWithView:(UIView *)view {
    NSAssert(view && [view isKindOfClass:[UIView class]], @" View must be a subclass instance of UIView! ");
    self = [self initWithFrame:view.bounds];
    if (!self) {
        return nil;
    }
    [self addToSuperView:view];
    return self;
}

- (void)addToSuperView:(UIView *)superView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    if ([superView isKindOfClass:[UIScrollView class]]) {
        superView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        self.alpha = 0.0;
    }
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat xy_navigationBarTopConstant = 0.0;
    if (orientation == UIDeviceOrientationPortrait) {
        xy_navigationBarTopConstant = 20.0;
    } else {
        xy_navigationBarTopConstant = 0.0;
    }
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    NSDictionary *subviewDict = @{@"nacBar": self};
    NSDictionary *metrics = @{@"navigationBarTop": @(xy_navigationBarTopConstant)};
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xy_willChangeStatusBarOrientationNotification) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    XYNavigationBarHeight barHeight = {64.0, 44.0};
    self.xy_navigationBarHeight = barHeight;
    
    [self.leftButton addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}


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
    [super setBackgroundColor:[UIColor clearColor]];
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void)setCustomView:(UIView *)customView {
    
    if (!customView) {
        return;
    }
    
    if (_customView) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    _customView = customView;
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    _customView.accessibilityIdentifier = @"customView";
    [self resetSubviews];
    [self.contentView addSubview:_customView];
}

- (void)setBackgroundViewTopConstant:(CGFloat)backgroundViewTopConstant {
    _backgroundViewTopConstant = backgroundViewTopConstant;
    if (!self.constraints.count) {
        return;
    }
    
    NSPredicate *backgroundTopPredicate = [NSPredicate predicateWithFormat:@"identifier == %@", @"XYNavigationBarBackgroundTopConstraint"];
    NSLayoutConstraint *backgroundTopConstraint = [self.constraints filteredArrayUsingPredicate:backgroundTopPredicate].firstObject;
    backgroundTopConstraint.constant = backgroundViewTopConstant;
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
    
    if ([_titleView isEqual:titleView] || _customView) {
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
    if (_titleButton == nil && _customView == nil) {
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
    
    if (_leftButton == nil && _customView == nil) {
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
        [self addSubview:contentView];
        _contentView = contentView;
        [self insertSubview:contentView aboveSubview:self.visualEffectView];
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

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        UIImageView *backgroundView = [[UIImageView alloc] init];
        backgroundView.backgroundColor = [UIColor clearColor];
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:backgroundView];
        _backgroundImageView = backgroundView;
        //        _backgroundImageView.image = [[self class] xy_imageFromColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        [self insertSubview:backgroundView aboveSubview:self.backgroundView];
    }
    return _backgroundImageView;
}

- (UIView *)backgroundView {
    if (_backgroundView == nil) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:backgroundView];
        _backgroundView = backgroundView;
        [self insertSubview:backgroundView atIndex:0];
    }
    return _backgroundView;
}
- (UIVisualEffectView *)visualEffectView {
    if (_visualEffectView == nil) {
        UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct];
        visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        visualEffectView.alpha = 1.0;
        [self addSubview:visualEffectView];
        _visualEffectView = visualEffectView;
        visualEffectView.userInteractionEnabled = NO;
        
    }
    return _visualEffectView;
}

- (void)setLeftButtonTitle:(nullable NSString *)title image:(nullable UIImage *)image forState:(UIControlState)state {
    
    _leftButtonTitle = title;
    _leftButtonImage = image;
    _backBarState = state;
    [self.leftButton setTitle:title forState:state];
    [self.leftButton setImage:image forState:state];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    self.backgroundImageView.image = backgroundImage;
}

- (UIImage *)backgroundImage {
    return self.backgroundImage;
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

- (void)setXy_navigationBarHeight:(XYNavigationBarHeight)xy_navigationBarHeight {
    if (_xy_navigationBarHeight.portraitOrientationHeight == xy_navigationBarHeight.portraitOrientationHeight && _xy_navigationBarHeight.otherOrientationHeight == xy_navigationBarHeight.otherOrientationHeight) {
        return;
    }
    _xy_navigationBarHeight = xy_navigationBarHeight;
    [self xy_willChangeStatusBarOrientationNotification];
}

#pragma mark - Notification

- (void)xy_willChangeStatusBarOrientationNotification {
    if (self.xy_willChangeStatusBarOrientationBlock) {
        self.xy_willChangeStatusBarOrientationBlock();
    }
    
    CGFloat navigationBarHeight = 0.0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationPortrait) {
        navigationBarHeight = self.xy_navigationBarHeight.portraitOrientationHeight;
        self.backgroundViewTopConstant = -20.0;
        self.xy_navigationBarTopConstant = 20.0;
    } else {
        navigationBarHeight = self.xy_navigationBarHeight.otherOrientationHeight;
        self.backgroundViewTopConstant = 0.0;
        self.xy_navigationBarTopConstant = 0.0;
    }
    
    // 修改navigationBar的高度
    NSInteger foundIndex = [self.constraints indexOfObjectPassingTest:^BOOL(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:@"topBarConstraintHeight"];
    }];
    
    if (foundIndex != NSNotFound) {
        NSLayoutConstraint *constraint = [self.constraints objectAtIndex:foundIndex];
        constraint.constant = navigationBarHeight;
        
    }
    else {
        
        NSLayoutConstraint *contentViewHConst = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:kNilOptions multiplier:1.0 constant:navigationBarHeight];
        contentViewHConst.identifier = @"topBarConstraintHeight";
        [self addConstraint:contentViewHConst];
    }
    
    // 修改navigationBar的top
    NSInteger foundNavigationTopConstraintIndex = [self.superview.constraints indexOfObjectPassingTest:^BOOL(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [obj.firstItem isEqual:self] && obj.firstAttribute == NSLayoutAttributeTop;
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    if (foundNavigationTopConstraintIndex != NSNotFound) {
        NSLayoutConstraint *constraint = [self.superview.constraints objectAtIndex:foundNavigationTopConstraintIndex];
        constraint.constant = self.xy_navigationBarTopConstant;
    }
}


#pragma mark - Private (auto layout)

- (void)updateConstraints {
    [self clearAllConstraints];
    
    NSDictionary *views = @{@"_contentView": self.contentView, @"_shadowLineView": self.shadowLineView, @"_backgroundImageView": self.backgroundImageView, @"_backgroundView": self.backgroundView, @"visualEffectView": self.visualEffectView};
    NSMutableDictionary *metrics = @{@"backgroundImageViewConstant": @(self.backgroundViewTopConstant)}.mutableCopy;
    
    // backgroundView
    NSLayoutConstraint *backgroundTopConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.backgroundViewTopConstant];
    backgroundTopConstraint.identifier = @"XYNavigationBarBackgroundTopConstraint";
    
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
    
    // backgroundImageView
    if ([self canShowBackgroundImageView]) {
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                               ]];
    }
    else {
        [_backgroundImageView removeFromSuperview];
        _backgroundImageView = nil;
    }
    
    // visualEffectView
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:self.visualEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:self.visualEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:self.visualEffectView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:self.visualEffectView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                           ]];
    
    // contentView
    NSArray *contentViewConstraints = @[
                                        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views],
                                        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views],
                                        ];
    
    [self addConstraints:[contentViewConstraints valueForKeyPath:@"@unionOfArrays.self"]];
    
    // 若有customView 则 让其与contentView的约束相同
    if (_customView) {
        NSArray *customViewConstraints = @[
                                           [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:@{@"customView": _customView}],
                                           [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:@{@"customView": _customView}]
                                           ];
        [self.contentView addConstraints:[customViewConstraints valueForKeyPath:@"@unionOfArrays.self"]];
    }
    else {
        
        // other
        if ([self canShowShadowLineView]) {
            [metrics addEntriesFromDictionary:@{@"shadowLineHeight": @(self.shadowLineHeight)}];
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
            [metrics addEntriesFromDictionary:@{@"leftButtonWidth": @(self.leftButton.intrinsicContentSize.width+10), @"leftButtonLeftM": @10}];
            NSDictionary *views = NSDictionaryOfVariableBindings(_leftButton);
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftButtonLeftM-[_leftButton(==leftButtonWidth)]" options:kNilOptions metrics:metrics views:views]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftButton]|" options:kNilOptions metrics:metrics views:views]];
        }
        else {
            [_leftButton removeFromSuperview];
            _leftButton = nil;
        }
        
        if ([self canshowRightButton]) {
            [metrics addEntriesFromDictionary:@{@"rightBtnRightM": @10, @"rightButtonWidth": @(self.rightButton.intrinsicContentSize.width+10)}];
            NSDictionary *views = NSDictionaryOfVariableBindings(_rightButton);
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightButton(==rightButtonWidth)]-rightBtnRightM-|" options:kNilOptions metrics:metrics views:views]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightButton]|" options:kNilOptions metrics:metrics views:views]];
        }
        else {
            [_rightButton removeFromSuperview];
            _rightButton = nil;
        }
        
        if ([self canShowTitleView]) {
            NSDictionary *views = NSDictionaryOfVariableBindings(_titleView);
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleView]|" options:kNilOptions metrics:metrics views:views]];
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

- (BOOL)canShowBackgroundImageView {
    return _backgroundImageView.image && _backgroundImageView.superview;
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
    
    self.shadowLineView.backgroundColor = [UIColor colorWithWhite:160/255.0 alpha:0.7];
    _hiddenLeftButton = NO;
    self.shadowLineHeight = 0.5;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationPortrait) {
        self.backgroundViewTopConstant = -20.0;
    } else {
        self.backgroundViewTopConstant = 0.0;
    }
    
}

- (void)leftBtnClick:(UIButton *)btn {
    if (self.leftButtonClick) {
        self.leftButtonClick();
    }
    
}

- (void)resetSubviews {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _leftButton = nil;
    _rightButton = nil;
    _titleView = nil;
    _titleButton = nil;
    [self clearAllConstraints];
}

- (void)clearAllConstraints {
    for (NSLayoutConstraint *constr in self.constraints.copy ) {
        if (![constr.firstItem isEqual:self]) {
            [self removeConstraint:constr];
        }
    }
    [self.contentView removeConstraints:self.contentView.constraints];
}

- (void)removeFromSuperview {
    
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && ([newSuperview isKindOfClass:[UIScrollView class]] || [newSuperview isKindOfClass:NSClassFromString(@"UILayoutContainerView")])) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.alpha = 1.0;
        } completion:NULL];
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


@implementation UIView (XYNavigationBarExtension)

+ (void)load {
    [super load];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeImplementationWithSelector:NSSelectorFromString(@"didMoveToSuperview") swizzledSelector:@selector(xy_didMoveToSuperview)];
    });
}

- (void)xy_didMoveToSuperview {
    NSUInteger foundIdx = [self.subviews indexOfObjectPassingTest:^BOOL(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [obj isKindOfClass:[XYNavigationBar class]];
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    if (foundIdx != NSNotFound) {
        XYNavigationBar *navigationBar = self.subviews[foundIdx];
        [self bringSubviewToFront:navigationBar];
    }
    
}

- (void)setOnceInstanceContentOffsetOrContentInset:(BOOL)onceInstanceContentOffsetOrContentInset {
    objc_setAssociatedObject(self, @selector(onceInstanceContentOffsetOrContentInset), @(onceInstanceContentOffsetOrContentInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)onceInstanceContentOffsetOrContentInset {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

@implementation NSObject (XYSwizzlingExtension)

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


@end

