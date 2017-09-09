//
//  XYProfileBaseController.h
//  
//
//  Created by mofeini on 16/9/25.
//  Copyright © 2016年 sey. All rights reserved.
//  自定义导航条的基类，请不要直接使用，若使用请继承自当前类



#import <UIKit/UIKit.h>
#import "XYCustomNavController.h"
#import "XYNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYProfileBaseController : UIViewController

@property (nonatomic, strong) XYNavigationBar *xy_navigationBar;

@end
NS_ASSUME_NONNULL_END


