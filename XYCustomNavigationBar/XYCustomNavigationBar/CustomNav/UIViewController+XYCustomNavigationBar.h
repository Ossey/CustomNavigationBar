//
//  UIViewController+XYCustomNavigationBar.h
//  XYCustomNavigationBar
//
//  Created by Swae on 10/09/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct  {
    float portraitOrientationHeight;
    float otherOrientationHeight;
}XYNavigationBarHeight;

NS_ASSUME_NONNULL_BEGIN

@interface XYNavigationBar : UIView

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong, readonly) UIView *shadowLineView;

@property (nonatomic, assign) CGFloat shadowLineHeight;

@property (nonatomic, weak) UIButton *rightButton;

/** 导航条自定义的titleView，当设置了titleView，属性title则无效 */
@property (nonatomic, weak) UIView *titleView;

/** 导航条title, 当设置了title，属性titleView则无效 */
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *titleColor;

/** 导航条左侧按钮和右侧按钮文字颜色 */
@property (nonatomic, strong) UIColor *tintColor;

/** 导航条左侧和右侧按钮文字字体 */
@property (nonatomic, strong) UIFont *buttonFont;

/** 是否隐藏导航条左侧按钮，默认隐藏 */
@property (nonatomic, assign, getter=isHiddenLeftButton) BOOL hiddenLeftButton;

@property (nonatomic, copy) void (^leftButtonClick)(void);

@property (nonatomic, assign) XYNavigationBarHeight xy_navigationBarHeight;

@property (nonatomic, strong) UIImage *backgroundImage;

- (void)setLeftButtonTitle:(nullable NSString *)title image:(nullable UIImage *)image forState:(UIControlState)state;

@end


@interface UIViewController (XYCustomNavigationBar)

@property (nonatomic, readonly) XYNavigationBar *xy_navigationBar;

- (void)backBtnClick;

@end

NS_ASSUME_NONNULL_END

