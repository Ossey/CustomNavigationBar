//
//  XYSearchNavigationView.m
//  AirbnbDemo
//
//  Created by Swae on 09/09/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "XYSearchNavigationView.h"

@interface XYSearchNavigationView ()

@property (nonatomic, weak) UIImageView *searchIconView;
@property (nonatomic, weak) UILabel *placeholderLbael;
@property (nonatomic, weak) UIView *contentView;

@end

@implementation XYSearchNavigationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnContentView:)]];
    
    NSDictionary *viewDict = @{@"searchIconView": self.searchIconView, @"placeholderLbael": self.placeholderLbael, @"contentView": self.contentView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(20.0)-[contentView]-(20.0)-|" options:kNilOptions metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15.0)-[contentView]-(15.0)-|" options:kNilOptions metrics:nil views:viewDict]];
    
    NSLayoutConstraint *searchIconWidthConstraint = [NSLayoutConstraint constraintWithItem:self.searchIconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:15.0];
    NSLayoutConstraint *searchIconHeightConstraint = [NSLayoutConstraint constraintWithItem:self.searchIconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.searchIconView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *searchIconCenterY = [NSLayoutConstraint constraintWithItem:self.searchIconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *placeholderLbaelTopConstraint = [NSLayoutConstraint constraintWithItem:self.placeholderLbael attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *placeholderLbaelBottomConstraint = [NSLayoutConstraint constraintWithItem:self.placeholderLbael attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    
    NSArray *viewConstraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20.0)-[searchIconView]-(20.0)-[placeholderLbael]-(20.0)-|" options:kNilOptions metrics:nil views:viewDict];
    NSArray *allConstrains = @[@[searchIconWidthConstraint, searchIconHeightConstraint, searchIconCenterY, placeholderLbaelBottomConstraint, placeholderLbaelTopConstraint],viewConstraintsH];
    
    [self addConstraints:[allConstrains valueForKeyPath:@"@unionOfArrays.self"]];
    
}


- (void)setPlaceholderTitle:(NSString *)placeholderTitle {
    _placeholderLbael.text = placeholderTitle;
}

- (NSString *)placeholderTitle {
    return _placeholderLbael.text;
}

- (UIImageView *)searchIconView {
    if (!_searchIconView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        _searchIconView = imageView;
        imageView.image = [UIImage imageNamed:@"new_explore_search_icon"];
        _searchIconView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _searchIconView;
}

- (UILabel *)placeholderLbael {
    if (!_placeholderLbael) {
        UILabel *label = [[UILabel alloc] init];
        [self.contentView addSubview:label];
        _placeholderLbael = label;
        _placeholderLbael.translatesAutoresizingMaskIntoConstraints = NO;
        _placeholderLbael.textColor = [UIColor colorWithWhite:0.5 alpha:0.8];
    }
    return _placeholderLbael;
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *view = [[UIView alloc] init];
        _contentView = view;
        [self addSubview:view];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 3.5;
        view.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.8].CGColor;
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = 1.0;
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)tapOnContentView:(UITapGestureRecognizer *)tap {
    if (self.searchClickBlock) {
        self.searchClickBlock(self);
    }
}

- (void)didMoveToSuperview {
    
    
}

@end
