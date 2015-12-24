//
//  UIView+DIBColors.m
//  DIBColors
//
//  Created by Jordan Morgan on 12/23/15.
//  Copyright © 2015 Dreaming In BInary LLC. All rights reserved.
//

#import "UIView+DIBColors.h"
#import "ColorScheme.h"
#import "ColorSchemeManager.h"
#import "UIColor+Utils.h"

@implementation UIView (DIBColors)
- (void)showColorPicker:(void (^)(NSArray *))completion
{
    ColorSchemeManager *colorManager = [[ColorSchemeManager alloc] initWithAvailableSpace:self.bounds];
    colorManager.colorSchemeBlock = completion;
    [self addSubview:colorManager];
    [colorManager layoutImages];
}

@end
