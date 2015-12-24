//
//  ColorScheme.h
//  Spendr
//
//  Created by Jordan Morgan on 12/27/12.
//  Copyright (c) 2013 Jordan Morgan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorScheme : UIView

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) UIView *fontAndTertiaryLayer;
@property (strong, nonatomic) UIView *secondaryLayer;
@property (strong, nonatomic) UIView *primaryLayer;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title colors:(NSArray *)colors;
- (void)animateScheme;
@end
