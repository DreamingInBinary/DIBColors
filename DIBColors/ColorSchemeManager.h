//
//  ColorSchemeManager.h
//  Spendr
//
//  Created by Jordan Morgan on 11/23/12.
//  Copyright (c) 2013 Jordan Morgan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, ColorSchemes){
    DefaultScheme,
    BlackoutScheme,
    RainyDayScheme,
    JamAndHoney,
    VitaminCScheme,
    OMGBUZYScheme,
    MuricaScheme,
    PinedScheme,
    CloudsScheme,
    DaisyScheme,
    LatteScheme,
    NurseryScheme,
    h2Oooo,
    PSL,
    Plum,
    Citrusish,
    Eclipse,
    StNick,
    ColorSchemeCount
};

@interface ColorSchemeManager : UIView

@property (strong, nonatomic) NSMutableArray *schemes;
@property (strong, nonatomic) UILabel *lblColorScheme;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *currentlySelectedSchemeColors;
@property NSInteger currentlySelectedScheme;
@property (copy, nonatomic) void (^colorSchemeBlock)(NSArray *);
@property (strong, nonatomic) UISwipeGestureRecognizer *swipe;

//This should be using the util method to find available space under a util scroller
- (id)initWithAvailableSpace:(CGRect)frame;
- (void)layoutImages;
- (void)removeImages;

+(NSArray *)getColorScheme:(ColorSchemes)scheme;
@end
