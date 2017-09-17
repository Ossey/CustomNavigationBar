//
//  XYSearchNavigationView.h
//  AirbnbDemo
//
//  Created by Swae on 09/09/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYSearchNavigationView : UIView

@property (nonatomic, copy) NSString *placeholderTitle;

@property (nonatomic, copy) void (^searchClickBlock)(XYSearchNavigationView *view);

@end
