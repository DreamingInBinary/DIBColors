//
//  UIView+DIBColors.h
//  DIBColors
//
//  Created by Jordan Morgan on 12/23/15.
//  Copyright © 2015 Dreaming In BInary LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DIBColors)
- (void)showColorPicker:(void (^)(NSArray *))completion;
@end
