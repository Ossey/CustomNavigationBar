//
//  UIViewController+XYNavigationBar.m
//  XYCustomNavigationBar
//
//  Created by Swae on 10/09/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "UIViewController+XYNavigationBar.h"
#import <objc/runtime.h>

typedef NSString * ImplementationKey NS_EXTENSIBLE_STRING_ENUM;


#pragma mark *** _WeakObjectContainer ***

@interface _WeakObjectContainer : NSObject

@property (nonatomic, weak, readonly) id weakObject;

- (instancetype)initWithWeakObject:(__weak id)weakObject;

@end

#pragma mark *** _SwizzlingObject ***

@interface _SwizzlingObject : NSObject

@property (nonatomic) Class swizzlingClass;
@property (nonatomic) SEL orginSelector;
@property (nonatomic) SEL swizzlingSelector;
@property (nonatomic) NSValue *swizzlingImplPointer;

@end

@interface NSObject (SwizzlingExtend)

@property (nonatomic, class, readonly) NSMutableDictionary<ImplementationKey, _SwizzlingObject *> *implementationDictionary;

- (Class)xy_baseClassToSwizzling;
- (void)hockSelector:(SEL)orginSelector swizzlingSelector:(SEL)swizzlingSelector;

@end

@interface XYNavigationBar ()

@property (nonatomic, strong) UIView *xy_topBar;     // 导航条xy_topBar
@property (nonatomic, strong) UIView *shadowLineView;        // 导航条阴影线
@property (nonatomic, strong) UIImage *xy_backBarImage;      // 导航条左侧返回按钮的图片
@property (nonatomic, assign) UIControlState xy_backBarState; // 导航条左侧返回按钮的状态
@property (nonatomic, weak) UIButton *leftButton;            // 导航条左侧按钮
@property (nonatomic, weak) UIButton *xy_titleButton;          // 导航条titleView
@property (nonatomic, copy) NSString *xy_backBarTitle;       // 导航条左侧返回按钮的文字，这个属性在当前控制器下有效


@end


@interface UIViewController ()

@property (nonatomic, assign) BOOL registerHock;

@end

@implementation UIViewController (XYNavigationBar)

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
    
    XYNavigationBar *xy_navigationBar = [[XYNavigationBar alloc] init];
    xy_navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:xy_navigationBar];
    NSDictionary *subviewDict = @{@"nacBar": xy_navigationBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nacBar]|" options:kNilOptions metrics:nil views:subviewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nacBar]" options:kNilOptions metrics:nil views:subviewDict]];
    [self xy_updateViewConstraints];
    [self registerHock];
    
    __weak typeof(self) selfVc = self;
    self.xy_navigationBar.backCompletionHandle = ^{
        [selfVc backBtnClick];
    };
    

    return xy_navigationBar;
}

- (BOOL)registerHock {
    BOOL flag = [objc_getAssociatedObject(self, _cmd) boolValue];
    if (!flag) {
        flag = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xy_updateViewConstraints) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        
        objc_setAssociatedObject(self, _cmd, @(flag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return flag;
}


- (void)xy_updateViewConstraints {
    CGFloat navigationBarHeight = 0.0;
    if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait) {
        navigationBarHeight = 64;
    }
    else {
        navigationBarHeight = 44;
    }
    
    NSInteger foundIndex = [self.view.constraints indexOfObjectPassingTest:^BOOL(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:@"topBarConstraintHeight"];
    }];
    
    if (foundIndex != NSNotFound) {
        NSLayoutConstraint *constraint = [self.view.constraints objectAtIndex:foundIndex];
        constraint.constant = navigationBarHeight;
        
    }
    else {
        
        NSLayoutConstraint *xy_topBarHConst = [NSLayoutConstraint constraintWithItem:self.xy_navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:navigationBarHeight];
        xy_topBarHConst.identifier = @"topBarConstraintHeight";
        [self.view addConstraint:xy_topBarHConst];
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


@synthesize xy_rightButton = _xy_rightButton;
@synthesize xy_titleButton = _xy_titleButton;
@synthesize xy_title = _xy_title;
@synthesize xy_backBarTitle = _xy_backBarTitle;
@synthesize xy_backBarImage = _xy_backBarImage;
@synthesize hiddenLeftButton = _hiddenLeftButton;
@synthesize xy_titleColor = _xy_titleColor;
@synthesize xy_tintColor = _xy_tintColor;


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
        [self addSubview:xy_topBar];
        [self bringSubviewToFront:xy_topBar];
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

- (BOOL)canShowLeftButton {
    if ([_leftButton titleForState:UIControlStateNormal] || [_leftButton attributedTitleForState:UIControlStateNormal].string.length > 0 || [_leftButton imageForState:UIControlStateNormal]) {
        return _leftButton.superview != nil;
    }
    return NO;
}

- (BOOL)canShowTitleButton {
    if ([_xy_titleButton titleForState:UIControlStateNormal] || [_xy_titleButton attributedTitleForState:UIControlStateNormal].string.length > 0 || [_xy_titleButton imageForState:UIControlStateNormal]) {
        return _xy_titleButton.superview != nil;
    }
    return NO;
}

- (BOOL)canShowTitleView {
    if (_xy_titleView.superview) {
        return YES;
    }
    return NO;
}


#pragma mark - Private (auto layout)
- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_xy_topBar, _shadowLineView);
    NSDictionary *metrics = @{@"leftButtonMaxW": @150, @"leftButtonLeftM": @10, @"leftBtnH": @44, @"rightBtnH": @44, @"rightBtnRightM": @10};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_xy_topBar]|" options:kNilOptions metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_xy_topBar]|" options:kNilOptions metrics:metrics views:views]];
    
    [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shadowLineView]|" options:kNilOptions metrics:metrics views:views]];
    [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_shadowLineView(0.5)]|" options:kNilOptions metrics:metrics views:views]];
    
    if ([self canShowTitleButton]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_leftButton);
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftButtonLeftM-[_leftButton(<=leftButtonMaxW)]" options:kNilOptions metrics:metrics views:views]];
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftButton(leftBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    
    if ([self canShowLeftButton]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_xy_rightButton);
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_xy_rightButton(<=leftButtonMaxW)]-rightBtnRightM-|" options:kNilOptions metrics:metrics views:views]];
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_xy_rightButton(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    else {
        [_leftButton removeFromSuperview];
        _leftButton = nil;
    }
    
    if (self.xy_titleButton && self.xy_titleButton.superview) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_xy_titleButton);
        [self.xy_topBar addConstraint:[NSLayoutConstraint constraintWithItem:self.xy_titleButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.xy_topBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.xy_topBar addConstraint:[NSLayoutConstraint constraintWithItem:self.xy_titleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:150]];
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_xy_titleButton(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
    }
    else {
        [_xy_titleButton removeFromSuperview];
        _xy_titleButton = nil;
    }
    
    if ([self canShowTitleView]) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_xy_titleView);
        [self.xy_topBar addConstraint:[NSLayoutConstraint constraintWithItem:self.xy_titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.xy_topBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.xy_topBar addConstraint:[NSLayoutConstraint constraintWithItem:self.xy_titleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:kNilOptions attribute:kNilOptions multiplier:0.0 constant:150]];
        [self.xy_topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_xy_titleView(rightBtnH)]|" options:kNilOptions metrics:metrics views:views]];
        
    }
    else {
        [_xy_titleView removeFromSuperview];
        _xy_titleView = nil;
    }
}

- (void)setupCustomBar {
    
    self.backgroundColor = [UIColor whiteColor];
    self.xy_topBar.backgroundColor = [UIColor colorWithWhite:242/255.0 alpha:0.7];
    
    self.shadowLineView.backgroundColor = [UIColor colorWithWhite:160/255.0 alpha:0.7];
    
    [self.leftButton addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
            //            vc.navigationController.navigationBar.userInteractionEnabled = NO;
            [vc.navigationController setNavigationBarHidden:YES];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *touchView = [super hitTest:point withEvent:event];
    
    return touchView;
}

@end


@implementation _WeakObjectContainer

- (instancetype)initWithWeakObject:(__weak id)weakObject {
    if (self = [super init]) {
        _weakObject = weakObject;
    }
    return self;
}

@end

@implementation _SwizzlingObject

- (NSString *)description {
    
    NSDictionary *descriptionDict = @{@"swizzlingClass": self.swizzlingClass,
                                      @"orginSelector": NSStringFromSelector(self.orginSelector),
                                      @"swizzlingImplPointer": self.swizzlingImplPointer};
    
    return [descriptionDict description];
}

@end

@implementation NSObject (SwizzlingExtend)

////////////////////////////////////////////////////////////////////////
#pragma mark - Method swizzling
////////////////////////////////////////////////////////////////////////


- (void)hockSelector:(SEL)orginSelector swizzlingSelector:(SEL)swizzlingSelector {
    
    // 本类未实现则return
    if (![self respondsToSelector:orginSelector]) {
        return;
    }
    
    NSLog(@"%@", self.implementationDictionary);
    
    for (_SwizzlingObject *implObject in self.implementationDictionary.allValues) {
        // 确保setImplementation 在UITableView or UICollectionView只调用一次, 也就是每个方法的指针只存储一次
        if (orginSelector == implObject.orginSelector && [self isKindOfClass:implObject.swizzlingClass]) {
            return;
        }
    }
    
    Class baseClas = [self xy_baseClassToSwizzling];
    ImplementationKey key = xy_getImplementationKey(baseClas, orginSelector);
    _SwizzlingObject *swizzleObjcet = [self.implementationDictionary objectForKey:key];
    NSValue *implValue = swizzleObjcet.swizzlingImplPointer;
    
    // 如果该类的实现已经存在，就return
    if (implValue || !key || !baseClas) {
        return;
    }
    
    // 注入额外的实现
    Method method = class_getInstanceMethod(baseClas, orginSelector);
    // 设置这个方法的实现
    IMP newImpl = method_setImplementation(method, (IMP)xy_orginalImplementation);
    
    // 将新实现保存到implementationDictionary中
    swizzleObjcet = [_SwizzlingObject new];
    swizzleObjcet.swizzlingClass = baseClas;
    swizzleObjcet.orginSelector = orginSelector;
    swizzleObjcet.swizzlingImplPointer = [NSValue valueWithPointer:newImpl];
    swizzleObjcet.swizzlingSelector = swizzlingSelector;
    [self.implementationDictionary setObject:swizzleObjcet forKey:key];
}

/// 根据类名和方法，拼接字符串，作为implementationDictionary的key
NSString * xy_getImplementationKey(Class clas, SEL selector) {
    if (clas == nil || selector == nil) {
        return nil;
    }
    
    NSString *className = NSStringFromClass(clas);
    NSString *selectorName = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@_%@", className, selectorName];
}

// 对原方法的实现进行加工
void xy_orginalImplementation(id self, SEL _cmd) {
    
    Class baseCls = [self xy_baseClassToSwizzling];
    ImplementationKey key = xy_getImplementationKey(baseCls, _cmd);
    _SwizzlingObject *swizzleObject = [[self implementationDictionary] objectForKey:key];
    NSValue *implValue = swizzleObject.swizzlingImplPointer;
    
    // 获取原方法的实现
    IMP impPointer = [implValue pointerValue];
    
    // 执行原实现
    if (impPointer) {
        ((void(*)(id, SEL))impPointer)(self, _cmd);
    }
    
    // 执行swizzing
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL swizzlingSelector = swizzleObject.swizzlingSelector;
    if ([self respondsToSelector:swizzlingSelector]) {
        [self performSelector:swizzlingSelector];
    }
#pragma clang diagnostic pop
}
+ (NSMutableDictionary *)implementationDictionary {
    static NSMutableDictionary *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSMutableDictionary dictionary];
    });
    return table;
}

- (NSMutableDictionary<ImplementationKey, _SwizzlingObject *> *)implementationDictionary {
    return self.class.implementationDictionary;
}

- (Class)xy_baseClassToSwizzling {
    return [self class];
}

@end
