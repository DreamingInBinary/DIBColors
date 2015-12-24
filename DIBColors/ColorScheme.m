//
//  ColorScheme.m
//  Spendr
//
//  Created by Jordan Morgan on 12/27/12.
//  Copyright (c) 2013 Jordan Morgan. All rights reserved.
//

#import "ColorScheme.h"
#import "AppDelegate.h"

#define kPrimaryColor 0
#define kSecondaryColor 1
#define kFontAndTertiaryColor 2

@implementation ColorScheme{
    UIColor *primaryColor;
    UIColor *secondaryColor;
    UIColor *fontAndTertiaryColor;
    UILabel *lblTitle;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title colors:(NSArray *)colors
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        self.colors = colors;
        primaryColor = (UIColor*)self.colors[kPrimaryColor];
        secondaryColor = (UIColor*)self.colors[kSecondaryColor];
        fontAndTertiaryColor = (UIColor*)self.colors[kFontAndTertiaryColor];
        [self createUI];
    }
    return self;
}

#pragma mark - UI Methods
- (void)createUI{
    //yourSubView.center = CGPointMake(yourView.bounds.size.width / 2, yourView.bounds.size.height / 2);
    //Alloc
    self.primaryLayer = [[UIView alloc] init];
    self.secondaryLayer = [[UIView alloc] init];
    self.fontAndTertiaryLayer = [[UIView alloc] init];
    
    //Color
    self.primaryLayer.backgroundColor = primaryColor;
    self.secondaryLayer.backgroundColor = secondaryColor;
    self.fontAndTertiaryLayer.backgroundColor = fontAndTertiaryColor;
    
    //Frames
    self.primaryLayer.frame = CGRectMake(0, 0, self.bounds.size.width * .45f, self.bounds.size.height * .45f);
    self.primaryLayer.layer.cornerRadius = self.primaryLayer.frame.size.width/2;
    self.secondaryLayer.frame = CGRectMake(0, 0, self.bounds.size.width * .65f, self.bounds.size.height * .65f);
    self.secondaryLayer.layer.cornerRadius = self.secondaryLayer.frame.size.width/2;
    self.fontAndTertiaryLayer.frame = CGRectMake(0, 0, self.bounds.size.width * .80f, self.bounds.size.height * .80f);
    self.fontAndTertiaryLayer.layer.cornerRadius = self.fontAndTertiaryLayer.frame.size.width/2;
    
    //Center them
    self.primaryLayer.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.secondaryLayer.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.fontAndTertiaryLayer.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    //Label
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height * .65f, self.bounds.size.width, self.bounds.size.height)];
    lblTitle.text = self.title;
    lblTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    lblTitle.textColor = fontAndTertiaryColor;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.adjustsFontSizeToFitWidth = YES;
    
    //Add
    [self addSubview:self.fontAndTertiaryLayer];
    [self addSubview:self.secondaryLayer];
    [self addSubview:self.primaryLayer];
    [self addSubview:lblTitle];
}

- (void)animateScheme{
    self.alpha = 1.0f;
    
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.primaryLayer.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.primaryLayer.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        }completion:nil];
    }];
    
    [UIView animateWithDuration:0.25f delay:0.00f options:UIViewAnimationOptionCurveEaseIn animations:^{
        lblTitle.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            lblTitle.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        }completion:nil];
    }];
    
    [UIView animateWithDuration:0.25f delay:0.10f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.secondaryLayer.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.secondaryLayer.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        }completion:nil];
    }];
    
    [UIView animateWithDuration:0.25f delay:0.20f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.fontAndTertiaryLayer.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.fontAndTertiaryLayer.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        }completion:nil];
    }];
}
@end
