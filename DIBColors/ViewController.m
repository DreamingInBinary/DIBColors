//
//  ViewController.m
//  DIBColors
//
//  Created by Jordan Morgan on 12/23/15.
//  Copyright © 2015 Dreaming In BInary LLC. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+Utils.h"   
#import "UIView+DIBColors.h"

@interface ViewController ()
@property (strong, nonatomic) UIView *primaryView;
@property (strong, nonatomic) UIView *secondaryView;
@property (strong, nonatomic) UIView *tertiaryView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self addShowColorsButton];
    [self addColorViews];
}

- (void)showColorPicker
{
    [self.view showColorPicker:^(NSArray *colors){
        self.primaryView.backgroundColor = colors[0];
        self.secondaryView.backgroundColor = colors[1];
        self.tertiaryView.backgroundColor = colors[2];
    }];
}

#pragma mark - Misc Functions - Not Related to Color Functionality
- (void)addShowColorsButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"Show Colors" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showColorPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [btn.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-60].active = YES;
    [btn.widthAnchor constraintEqualToConstant:220].active = YES;
    [btn.heightAnchor constraintEqualToConstant:40].active = YES;
    btn.layer.cornerRadius = 20;

    btn.backgroundColor = [UIColor colorFromHexCode:@"2ecc71"];
}

- (void)addColorViews
{
    self.primaryView = [UIView new];
    self.primaryView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.primaryView];
    self.primaryView.backgroundColor = [UIColor redColor];
    self.secondaryView = [UIView new];
    self.secondaryView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.secondaryView];
    self.secondaryView.backgroundColor = [UIColor greenColor];
    self.tertiaryView = [UIView new];
    self.tertiaryView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tertiaryView];
    self.tertiaryView.backgroundColor = [UIColor blueColor];
    
    [self.primaryView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.secondaryView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.tertiaryView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    [self.primaryView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.secondaryView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.tertiaryView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    
    CGFloat height = (self.view.bounds.size.height * .10);
    [self.primaryView.heightAnchor constraintEqualToConstant:height].active = YES;
    [self.secondaryView.heightAnchor constraintEqualToConstant:height].active = YES;
    [self.tertiaryView.heightAnchor constraintEqualToConstant:height].active = YES;
    
    [self.primaryView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.secondaryView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:height].active = YES;
    [self.tertiaryView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:height * 2].active = YES;
}
@end
