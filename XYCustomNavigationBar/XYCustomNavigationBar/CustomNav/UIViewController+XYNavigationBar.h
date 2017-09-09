//
//  UIViewController+XYNavigationBar.h
//  XYCustomNavigationBar
//
//  Created by Swae on 10/09/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface XYNavigationBar : UIView

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong, readonly) UIView *shadowLineView;

@property (nonatomic, weak) UIButton *rightButton;

/** 导航条自定义的titleView， 注意: 当设置了titleView，属性title则无效 */
@property (nonatomic, weak) UIView *titleView;

/** 导航条title , 注意: 当设置了title，属性titleView则无效 */
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *titleColor;

/** 导航条左侧按钮和右侧按钮文字颜色 */
@property (nonatomic, strong) UIColor *tintColor;

/** 导航条左侧和右侧按钮文字字体 */
@property (nonatomic, strong) UIFont *buttonFont;

/** 是否隐藏导航条左侧按钮，默认隐藏 */
@property (nonatomic, assign, getter=isHiddenLeftButton) BOOL hiddenLeftButton;

- (void)setLeftButtonTitle:(nullable NSString *)title image:(nullable UIImage *)image forState:(UIControlState)state;

/**
 * @explain 自定义顶部bar的左侧返回按钮的点击事件，注意: 非特殊情况下，请不要重写这个方法，不然会造成方法内部实现无效；
 *          此种情况需要重写此方法: 比如在modal的基础上push的控制器，需要重新此方法调用pop方法返回哦
 */
@property (nonatomic, copy) void (^backCompletionHandle)();

@end



@interface UIViewController (XYNavigationBar)

@property (nonatomic, readonly) XYNavigationBar *xy_navigationBar;

- (void)backBtnClick;

@end

NS_ASSUME_NONNULL_END
