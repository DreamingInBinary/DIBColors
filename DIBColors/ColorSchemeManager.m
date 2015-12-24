//
//  ColorSchemeManager.m
//  Spendr
//
//  Created by Jordan Morgan on 11/23/12.
//  Copyright (c) 2013 Jordan Morgan. All rights reserved.
//

#import "ColorScheme.h"
#import "ColorSchemeManager.h"
#import "UIColor+Utils.h"

#define kPrimaryColor 0
#define kSecondaryColor 1
#define kFontAndTertiaryColor 2
#define kSchemesPerPage 5
#define kSchemeWidth 80
#define kSchemeHeight 80
#define topleft 0
#define topMiddle 1
#define topRight 2
#define bottomLeft 3
#define bottomMiddle 4
#define bottomRight 5

//Scheme indicies - determines where they lay out and colors, etc
#define kDefaultTheme 0
#define kBlackoutTheme 1
#define kRainyDay 2
#define kJamAndHoney 3
#define kVitamin_C 4
#define kOMGBUZYTheme 5
#define kMuricaTheme 6
#define kPinedTheme 7
#define kClouds 8
#define kDaisyTheme 9
#define kLatte 10
#define kNursery 11
#define kh2Oooo 12
#define kPSL 13
#define kPlum 14
#define kCitrusish 15
#define kEclipse 16
#define kStNick 17

#define kSpellCheckKey @"Spellcheck"
#define kVibrationsKey @"Vibrations"
#define kSoundsKey @"Sounds"
#define kShakeToCancelKey @"Shake"
#define kMotionEffectsKey @"Motions"

@implementation ColorSchemeManager{
    float scrollWidth;
    int pageCheck;
    BOOL needsNextPage;
    CGSize zoneSize;
    CGRect scrollFrame;
    CGFloat kParallaxIntensity;
}

#pragma mark - INIT METHODS
- (id)initWithAvailableSpace:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        //Call layoutImages if you want the UI
        
        kParallaxIntensity = 30.0f;
        
        //This will make no ColorScheme selected when alloc'd
        self.currentlySelectedScheme = -1;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kMotionEffectsKey] == NO) kParallaxIntensity = 0.0f;
    }
    
    return self;
}

#pragma mark - SCROLLVIEW/LABEL
- (void)setUpScrollView{
    scrollFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height * 0.75f);
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    [self addSubview:self.scrollView];
}

- (void)setUpLabel{
    self.lblColorScheme = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                    self.scrollView.bounds.size.height,
                                                                    self.bounds.size.width,
                                                                    (self.bounds.size.height - self.scrollView.bounds.size.height))];
    
    self.lblColorScheme.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.lblColorScheme.textColor = [UIColor whiteColor];
    self.lblColorScheme.textAlignment = NSTextAlignmentCenter;
    self.lblColorScheme.text = [self getColorSchemeBlurbFromIndex:kDefaultTheme];
    self.lblColorScheme.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.lblColorScheme];
    self.lblColorScheme.alpha = 0.0f;
}

//Used when a ColorScheme object is touched
-(void)transformLabelAndSetText:(NSString *)newText withColor:(UIColor *)colorIn{
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.lblColorScheme.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        self.lblColorScheme.alpha = 0.0f;
    }completion:^ (BOOL finished){
        self.lblColorScheme.textColor = colorIn;
        self.lblColorScheme.text = newText;
        self.lblColorScheme.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        self.lblColorScheme.alpha = 1.0f;
    }];
}

#pragma mark - COLOR SCHEME CIRCLES
//Used when ColorSchemeManager is alloc'd
- (void)createAndAddSchemeCirclesToViewInBounds{
    /*
        1) Figure out the contentSize of the scrollview
        2) Figure out the frames for each of the six spots they can be at
        3) Check to see if we are at a multiple of six, if we are, scoot to the next page
     */
    
    zoneSize = CGSizeMake(self.scrollView.bounds.size.width/3, self.scrollView.bounds.size.height/2);
    pageCheck = 0;
    needsNextPage = NO;
    scrollWidth = self.bounds.size.width;
    self.scrollView.contentSize = CGSizeMake(scrollWidth, self.scrollView.frame.size.height);
    self.schemes = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *tap;
    
    for (int count = 0; count < ColorSchemeCount; count++) {
        //Check for next page first
        [self managePageAdditions];
        
        //Set up the scheme
        ColorScheme *scheme = [[ColorScheme alloc]
                               initWithFrame:[self determineSchemeCircleFrameFromCount:pageCheck]
                               title:[self getColorSchemeTitleFromIndex:count]
                               colors:[self getColorSchemeFromIndex:count]];
        scheme.tag = count;
        tap = [[UITapGestureRecognizer alloc]
               initWithTarget:self
               action:@selector(schemeTouchedAtIndex:)];
        tap.cancelsTouchesInView = NO;
        [scheme addGestureRecognizer:tap];
        [self.scrollView addSubview:scheme];
        [self.schemes addObject:scheme];
        
        //See if next pass requires a new page or not
        if(pageCheck > 0) needsNextPage = (pageCheck % kSchemesPerPage == 0);
        needsNextPage ? pageCheck = 0 : pageCheck++;
    }
    
    //Otherwise the ColorSchemes will zoom behind the label
    self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.frame.size.height);

}

//Adds width to the contentSize of the scrollview
- (void)managePageAdditions{
    if(needsNextPage){
        //Create a new page
        scrollFrame = CGRectMake(scrollFrame.origin.x + self.bounds.size.width, scrollFrame.origin.y,
                                     scrollFrame.size.width, scrollFrame.size.height);
        scrollWidth += self.bounds.size.width;
        self.scrollView.contentSize = CGSizeMake(scrollWidth, self.scrollView.frame.size.height);
        needsNextPage = NO;
    }
}

//Creates the correct frame for the scheme, used when a ColorScheme is alloc'd
- (CGRect)determineSchemeCircleFrameFromCount:(int)countIn{
    //See if we are in top left,mid,right or bottom left,mid,right
    CGRect zoneRect = CGRectZero;
    CGRect schemeRect = CGRectZero;
    switch (countIn) {
        case topleft:
            zoneRect = CGRectMake(scrollFrame.origin.x, 0, zoneSize.width, zoneSize.height);
            schemeRect = CGRectMake(zoneRect.origin.x + (zoneRect.size.width/2) - (kSchemeWidth/2),
                                    zoneRect.origin.y + (zoneRect.size.height/2) - (kSchemeHeight/2),
                                    kSchemeWidth,
                                    kSchemeHeight);
            return schemeRect;
            break;
        case topMiddle:
            zoneRect = CGRectMake(scrollFrame.origin.x + zoneSize.width, 0, zoneSize.width, zoneSize.height);
            schemeRect = CGRectMake(zoneRect.origin.x + (zoneRect.size.width/2) - (kSchemeWidth/2),
                                    zoneRect.origin.y + (zoneRect.size.height/2) - (kSchemeHeight/2),
                                    kSchemeWidth,
                                    kSchemeHeight);
            return schemeRect;
            break;
        case topRight:
            zoneRect = CGRectMake(scrollFrame.origin.x + (zoneSize.width * 2), 0, zoneSize.width, zoneSize.height);
            schemeRect = CGRectMake(zoneRect.origin.x + (zoneRect.size.width/2) - (kSchemeWidth/2),
                                    zoneRect.origin.y + (zoneRect.size.height/2) - (kSchemeHeight/2),
                                    kSchemeWidth,
                                    kSchemeHeight);
            return schemeRect;
            break;
        case bottomLeft:
            zoneRect = CGRectMake(scrollFrame.origin.x, zoneSize.height, zoneSize.width, zoneSize.height);
            schemeRect = CGRectMake(zoneRect.origin.x + (zoneRect.size.width/2) - (kSchemeWidth/2),
                                    zoneRect.origin.y + (zoneRect.size.height/2) - (kSchemeHeight/2),
                                    kSchemeWidth,
                                    kSchemeHeight);
            return schemeRect;
            break;
        case bottomMiddle:
            zoneRect = CGRectMake(scrollFrame.origin.x + zoneSize.width, zoneSize.height, zoneSize.width, zoneSize.height);
            schemeRect = CGRectMake(zoneRect.origin.x + (zoneRect.size.width/2) - (kSchemeWidth/2),
                                    zoneRect.origin.y + (zoneRect.size.height/2) - (kSchemeHeight/2),
                                    kSchemeWidth,
                                    kSchemeHeight);;
            return schemeRect;
            break;
        case bottomRight:
            zoneRect = CGRectMake(scrollFrame.origin.x +(zoneSize.width * 2), zoneSize.height,
                                  zoneSize.width, zoneSize.height);
            schemeRect = CGRectMake(zoneRect.origin.x + (zoneRect.size.width/2) - (kSchemeWidth/2),
                                    zoneRect.origin.y + (zoneRect.size.height/2) - (kSchemeHeight/2),
                                    kSchemeWidth,
                                    kSchemeHeight);
            return schemeRect;
            break;
        default:
            return schemeRect;
            break;
    }
}

//Gets all the colors of a scheme from its index, used when a ColorScheme is alloc'd in a loop
- (NSArray *)getColorSchemeFromIndex:(int)index{
    switch (index) {
        case kDefaultTheme:
            return [ColorSchemeManager getColorScheme:DefaultScheme];
            break;
        case kBlackoutTheme:
            return [ColorSchemeManager getColorScheme:BlackoutScheme];
            break;
        case kMuricaTheme:
            return [ColorSchemeManager getColorScheme:MuricaScheme];
            break;
        case kJamAndHoney:
            return [ColorSchemeManager getColorScheme:JamAndHoney];
            break;
        case kVitamin_C:
            return [ColorSchemeManager getColorScheme:VitaminCScheme];
            break;
        case kOMGBUZYTheme:
            return [ColorSchemeManager getColorScheme:OMGBUZYScheme];
            break;
        case kRainyDay:
            return [ColorSchemeManager getColorScheme:RainyDayScheme];
            break;
        case kPinedTheme:
            return [ColorSchemeManager getColorScheme:PinedScheme];
            break;
        case kClouds:
            return [ColorSchemeManager getColorScheme:CloudsScheme];
            break;
        case kDaisyTheme:
            return [ColorSchemeManager getColorScheme:DaisyScheme];
            break;
        case kLatte:
            return [ColorSchemeManager getColorScheme:LatteScheme];
            break;
        case kNursery:
            return [ColorSchemeManager getColorScheme:NurseryScheme];
            break;
        case kh2Oooo:
            return [ColorSchemeManager getColorScheme:h2Oooo];
            break;
        case kPSL:
            return [ColorSchemeManager getColorScheme:PSL];
            break;
        case kPlum:
            return [ColorSchemeManager getColorScheme:Plum];
            break;
        case kCitrusish:
            return [ColorSchemeManager getColorScheme:Citrusish];
            break;
        case kEclipse:
            return [ColorSchemeManager getColorScheme:Eclipse];
            break;
        case kStNick:
            return [ColorSchemeManager getColorScheme:StNick];
            break;
        default:
            return [ColorSchemeManager getColorScheme:DefaultScheme];
            break;
    }
}

//Gets the blurb for the color scheme from its index
- (NSString *)getColorSchemeBlurbFromIndex:(int)index{
    switch (index) {
        case kDefaultTheme:
            return @"The classic";
            break;
        case kBlackoutTheme:
            return @"Kill the lights";
            break;
        case kMuricaTheme:
            return @"Oh hail, can ye see?";
            break;
        case kJamAndHoney:
            return @"Win - Win";
            break;
        case kVitamin_C:
            return @"Scientifically, you can't get enough";
            break;
        case kOMGBUZYTheme:
            return @"S0 HYp3R bR0!";
            break;
        case kRainyDay:
            return @"Hey, a little water never hurt anyone.";
            break;
        case kPinedTheme:
            return @"The great outdoors, on your phone";
            break;
        case kClouds:
            return @"Cumulstrcirunimbus...ish";
            break;
        case kDaisyTheme:
            return @"Because flowers";
            break;
        case kLatte:
            return @"I <3 C8H10N4O2";
            break;
        case kNursery:
            return @"Minus the crying";
        case kh2Oooo:
            return @"Liquid life";
            break;
        case kPSL:
            return @"#Pumpkin Spice La...drink";
            break;
        case kPlum:
            return @"Such plum. Much flower. Woooooow.";
            break;
        case kCitrusish:
            return @"Dat fruit tho";
            break;
        case kEclipse:
            return @"Only happens once every...time you open your phone";
            break;
        case kStNick:
            return @"Mistletoe! Presents! ...In-Laws";
            break;
        default:
            return @"Fancy a color scheme?";
            break;
    }

}

//Gets the actual title of the color scheme from the index, used when a ColorScheme is alloc'd
- (NSString *)getColorSchemeTitleFromIndex:(int)index{
    switch (index) {
        case kDefaultTheme:
            return @"Spend Stack";
            break;
        case kBlackoutTheme:
            return @"Blackout";
            break;
        case kMuricaTheme:
            return @"Murica'";
            break;
        case kJamAndHoney:
            return @"Jam & Honey";
            break;
        case kVitamin_C:
            return @"Vitamin C";
            break;
        case kOMGBUZYTheme:
            return @"OMGBUZY";
            break;
        case kRainyDay:
            return @"Rainy Day";
            break;
        case kPinedTheme:
            return @"Pined";
            break;
        case kClouds:
            return @"Clouds";
            break;
        case kDaisyTheme:
            return @"Daisy";
            break;
        case kLatte:
            return @"Latte";
            break;
        case kNursery:
            return @"Nursery";
            break;
        case kh2Oooo:
            return @"H2Ohhh";
            break;
        case kPSL:
            return @"#PSL";
            break;
        case kPlum:
            return @"Plum";
            break;
        case kCitrusish:
            return @"Citrusish";
            break;
        case kEclipse:
            return @"Eclipse";
            break;
        case kStNick:
            return @"St.Nick";
            break;
        default:
            return @"Spend Stack";
            break;
    }
}

//Handles when a scheme is touched
- (void)schemeTouchedAtIndex:(UITapGestureRecognizer *)gesture{
    [self dimSchemesExceptSchemeWithTag:gesture.view.tag];
    [(ColorScheme *)gesture.view setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
    
    
    switch (gesture.view.tag) {
        case kDefaultTheme:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kDefaultTheme]
                                 withColor:[ColorSchemeManager getColorScheme:DefaultScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kDefaultTheme] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kDefaultTheme];

            //Set this so if they user scrolls away and back, the right one will be selected
            self.currentlySelectedScheme = kDefaultTheme;
            
            //Perform whatever you need to do in the parent VC
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kBlackoutTheme:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kBlackoutTheme]
                                 withColor:[ColorSchemeManager getColorScheme:BlackoutScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kBlackoutTheme] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kBlackoutTheme];

            self.currentlySelectedScheme = kBlackoutTheme;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kMuricaTheme:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kMuricaTheme]
                                 withColor:[ColorSchemeManager getColorScheme:MuricaScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kMuricaTheme] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kMuricaTheme];

            self.currentlySelectedScheme = kMuricaTheme;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kJamAndHoney:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kJamAndHoney]
                                 withColor:[ColorSchemeManager getColorScheme:JamAndHoney][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kJamAndHoney] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kJamAndHoney];
            
            self.currentlySelectedScheme = kJamAndHoney;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kVitamin_C:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kVitamin_C]
                                 withColor:[ColorSchemeManager getColorScheme:VitaminCScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kVitamin_C] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kVitamin_C];
            
            self.currentlySelectedScheme = kVitamin_C;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kOMGBUZYTheme:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kOMGBUZYTheme]
                                 withColor:[ColorSchemeManager getColorScheme:OMGBUZYScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kOMGBUZYTheme] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kOMGBUZYTheme];

            self.currentlySelectedScheme = kOMGBUZYTheme;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kRainyDay:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kRainyDay]
                                 withColor:[ColorSchemeManager getColorScheme:RainyDayScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kRainyDay] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kRainyDay];
            
            self.currentlySelectedScheme = kRainyDay;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kPinedTheme:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kPinedTheme]
                                 withColor:[ColorSchemeManager getColorScheme:PinedScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kPinedTheme] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kPinedTheme];
            
            self.currentlySelectedScheme = kPinedTheme;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kClouds:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kClouds]
                                 withColor:[ColorSchemeManager getColorScheme:CloudsScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kClouds] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kClouds];
            
            self.currentlySelectedScheme = kClouds;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kDaisyTheme:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kDaisyTheme]
                                 withColor:[ColorSchemeManager getColorScheme:DaisyScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kDaisyTheme] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kDaisyTheme];
            
            self.currentlySelectedScheme = kDaisyTheme;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kLatte:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kLatte]
                                 withColor:[ColorSchemeManager getColorScheme:LatteScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kLatte] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kLatte];
            
            self.currentlySelectedScheme = kLatte;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kNursery:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kNursery]
                                 withColor:[ColorSchemeManager getColorScheme:NurseryScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kNursery] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kNursery];
            
            self.currentlySelectedScheme = kNursery;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kh2Oooo:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kh2Oooo]
                                 withColor:[ColorSchemeManager getColorScheme:NurseryScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kh2Oooo] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kh2Oooo];
            
            self.currentlySelectedScheme = kh2Oooo;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kPSL:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kPSL]
                                 withColor:[ColorSchemeManager getColorScheme:NurseryScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kPSL] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kPSL];
            
            self.currentlySelectedScheme = kPSL;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kPlum:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kPlum]
                                 withColor:[ColorSchemeManager getColorScheme:NurseryScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kPlum] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kPlum];
            
            self.currentlySelectedScheme = kPlum;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kCitrusish:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kCitrusish]
                                 withColor:[ColorSchemeManager getColorScheme:NurseryScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kCitrusish] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kCitrusish];
            
            self.currentlySelectedScheme = kCitrusish;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kEclipse:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kEclipse]
                                 withColor:[ColorSchemeManager getColorScheme:NurseryScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kEclipse] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kEclipse];
            
            self.currentlySelectedScheme = kEclipse;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        case kStNick:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kStNick]
                                 withColor:[ColorSchemeManager getColorScheme:NurseryScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kStNick] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:kStNick];
            
            self.currentlySelectedScheme = kStNick;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
        default:
            [self transformLabelAndSetText:[self getColorSchemeBlurbFromIndex:kOMGBUZYTheme]
                                 withColor:[ColorSchemeManager getColorScheme:OMGBUZYScheme][kFontAndTertiaryColor]];
            [(ColorScheme *)[self.schemes objectAtIndex:kOMGBUZYTheme] animateScheme];
            
            //Expose choice to outside VC
            self.currentlySelectedSchemeColors = [self getColorSchemeFromIndex:DefaultScheme];
            
            self.currentlySelectedScheme = kDefaultTheme;
            
            self.colorSchemeBlock(self.currentlySelectedSchemeColors);
            break;
    }
}

- (void)addDoneButton {
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat vwHeight = self.bounds.size.height;
    CGFloat vwWidth = self.bounds.size.width;
    doneBtn.alpha = 0.0f;
    doneBtn.frame = CGRectMake(vwWidth/2 - 50, vwHeight, 100, 26);
    doneBtn.layer.cornerRadius = 13;
    doneBtn.layer.borderWidth = 1;
    doneBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    doneBtn.tag = 909;
    [self addSubview:doneBtn];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(removeImages) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.2 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
        doneBtn.frame = CGRectMake(vwWidth/2 - 50, vwHeight - 36, 100, 26);
        doneBtn.alpha = 1.0f;
    }completion:nil];
}

//Should only be called inside [self layoutImages]
- (void)performAnimationsForUI {
    //Holds all the correct position for where the ColorSchemes need to go
    NSMutableArray *rects = [[NSMutableArray alloc] init];
    CGRect targetLabelFrame = self.lblColorScheme.frame;
    self.scrollView.userInteractionEnabled = NO;
    
    //Setup the label before it slides up
    self.lblColorScheme.text = [self getColorSchemeBlurbFromIndex:(int)self.currentlySelectedScheme];
    self.lblColorScheme.textColor = [self getColorSchemeFromIndex:(int)self.currentlySelectedScheme][kFontAndTertiaryColor];
    
    //Get frames for reference, they are already at the right spots but we need to animate the first six in
    for (ColorScheme *schemes in self.schemes) {
        [rects addObject:[NSValue valueWithCGRect:schemes.frame]];
        schemes.alpha = 1.0f;
    }
    
    //Nudge down the label so it comes from the top
    self.lblColorScheme.frame = CGRectMake(0, self.superview.frame.size.height + targetLabelFrame.size.height, targetLabelFrame.size.width, targetLabelFrame.size.height);
    
    //Set frame to zoom in from top
    [(ColorScheme *)self.schemes[0] setFrame:CGRectMake(self.superview.frame.origin.x - 100, self.superview.frame.origin.y - 200, 400, 400)];
    [(ColorScheme *)self.schemes[1] setFrame:CGRectMake((self.superview.frame.size.width/2) - 200, self.superview.frame.origin.y - 200, 400, 400)];
    [(ColorScheme *)self.schemes[2] setFrame:CGRectMake(self.superview.frame.size.width + 100, self.superview.frame.origin.y - 200, 400, 400)];
    
    //Set frame to zoom in from bottom
    [(ColorScheme *)self.schemes[3] setFrame:CGRectMake(self.superview.frame.origin.x - 100, self.superview.frame.size.height + 200, 66, 66)];
    [(ColorScheme *)self.schemes[4] setFrame:CGRectMake((self.superview.frame.size.width/2) - 200, self.superview.frame.size.height + 200, 400, 400)];
    [(ColorScheme *)self.schemes[5] setFrame:CGRectMake(self.superview.frame.size.width + 100, self.superview.frame.size.height + 200, 400, 400)];

    //Animate them in
    [UIView animateWithDuration:0.10f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [(ColorScheme *)self.schemes[0] setFrame:[rects[0] CGRectValue]];
    }completion:nil];
    
    //Animate them in
    [UIView animateWithDuration:0.20f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [(ColorScheme *)self.schemes[1] setFrame:[rects[1] CGRectValue]];
    }completion:nil];
    
    //Animate them in
    [UIView animateWithDuration:0.30f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [(ColorScheme *)self.schemes[2] setFrame:[rects[2] CGRectValue]];
    }completion:nil];
    
    //Animate them in
    [UIView animateWithDuration:0.40f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [(ColorScheme *)self.schemes[3] setFrame:[rects[3] CGRectValue]];
    }completion:nil];
    
    //Animate them in
    [UIView animateWithDuration:0.50f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [(ColorScheme *)self.schemes[4] setFrame:[rects[4] CGRectValue]];
    }completion:nil];
    
    //Animate them in
    [UIView animateWithDuration:0.60f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [(ColorScheme *)self.schemes[5] setFrame:[rects[5] CGRectValue]];
    }completion:nil];
    
    //Label
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.lblColorScheme.frame = targetLabelFrame;
        self.lblColorScheme.alpha = 1.0f;
    }completion:^(BOOL finished){
        self.scrollView.userInteractionEnabled = YES;
        [self dimSchemesExceptSchemeWithTag:self.currentlySelectedScheme];

    }];

}

//Sets up the entire UI
- (void)layoutImages{
    
    //Dimming
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = self.bounds;
    [self addSubview:effectView];
    
    //Set up scrollview
    [self setUpScrollView];
    
    //Set up label
    [self setUpLabel];
    
    //Set up color scheme objects
    [self createAndAddSchemeCirclesToViewInBounds];
    
    //Done button
    [self addDoneButton];
    
    //Animates them in
    [self performAnimationsForUI];
}

//Dims all the schemes alpha to .75 except the one that was pressed
- (void)dimSchemesExceptSchemeWithTag:(NSInteger)tag{
    //Make sure everything is dimmed
    for (ColorScheme *schemes in self.schemes) {
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (schemes.tag != tag) {
                schemes.alpha = .75f;
                schemes.transform = CGAffineTransformMakeScale(.5f, .5f);
            }
        }completion:nil];
    }
}

//Nuke UI
- (void)removeImages{
    __block NSInteger randomX;
    
    //Handle the label
    UIButton *done = [self viewWithTag:909];
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        self.lblColorScheme.alpha = 0.0f;
        done.alpha = 0.0f;
    }completion:^ (BOOL finished){
        [self.lblColorScheme removeFromSuperview];
        [done removeFromSuperview];
    }];

    //Animate them out
    for(ColorScheme *scheme in self.schemes){
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            randomX = arc4random() % (NSInteger)(scheme.frame.origin.x + 40);
            scheme.frame = CGRectMake(randomX, self.frame.size.height, 0, 0);
            scheme.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
            scheme.alpha = 0.5f;
        }completion:^ (BOOL finished){
            if (finished) {
                [scheme removeFromSuperview];
                [self.scrollView removeFromSuperview];
                [self removeFromSuperview];
            }
        }];
    }

}

#pragma mark - CLASS METHODS
+(NSArray *)getColorScheme:(ColorSchemes)scheme{
    NSArray *colors;
    UIColor *primary;
    UIColor *secondary;
    UIColor *fontAndTertiary;
    BOOL shouldUseLightKeyboard;
    
    switch (scheme) {
        case DefaultScheme:
            primary = [UIColor colorFromHexCode:@"C5333E"];
            secondary = [UIColor colorFromHexCode:@"4BB5C1"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case BlackoutScheme:
            primary = [UIColor colorFromHexCode:@"2C3E50"];
            secondary = [UIColor colorFromHexCode:@"0D0506"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = NO;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case MuricaScheme:
            primary = [UIColor colorFromHexCode:@"C60708"];
            secondary = [UIColor colorFromHexCode:@"001D5A"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case JamAndHoney:
            primary = [UIColor colorWithRed:79.0/255.0f green:0.0/255.0f blue:178.0/255.0f alpha:1.0];
            secondary = [UIColor colorFromHexCode:@"FF8900"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case VitaminCScheme:
            primary = [UIColor colorFromHexCode:@"004358"];
            secondary = [UIColor colorFromHexCode:@"1F8A70"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = NO;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case OMGBUZYScheme:
            primary = [UIColor colorFromHexCode:@"FF00E6"];
            secondary = [UIColor colorFromHexCode:@"712662"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case RainyDayScheme:
            primary = [UIColor colorFromHexCode:@"046380"];
            secondary = [UIColor colorFromHexCode:@"9FB4CC"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case PinedScheme:
            primary = [UIColor colorFromHexCode:@"573828"];
            secondary = [UIColor colorWithRed:22.0/255.0f green:160.0/255.0f blue:134.0/255.0f alpha:1.0];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = NO;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case CloudsScheme:
            primary = [UIColor colorFromHexCode:@"ABC8E2"];
            secondary = [UIColor colorFromHexCode:@"9FBCBF"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case DaisyScheme:
            primary = [UIColor colorFromHexCode:@"0583F2"];
            secondary = [UIColor colorFromHexCode:@"F1CE00"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case LatteScheme:
            primary = [UIColor colorFromHexCode:@"803D22"];
            secondary = [UIColor colorFromHexCode:@"4D2B1F"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = NO;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case NurseryScheme:
            primary = [UIColor colorFromHexCode:@"78C0F9"];
            secondary = [UIColor colorFromHexCode:@"FFABBE"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case h2Oooo:
            primary = [UIColor colorFromHexCode:@"2980BA"];
            secondary = [UIColor colorFromHexCode:@"1ABD9C"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case PSL:
            primary = [UIColor colorFromHexCode:@"2C3E50"];
            secondary = [UIColor colorFromHexCode:@"D35400"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case Plum:
            primary = [UIColor colorFromHexCode:@"8E44AD"];
            secondary = [UIColor colorFromHexCode:@"E74C3C"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case Citrusish:
            primary = [UIColor colorFromHexCode:@"27AE60"];
            secondary = [UIColor colorFromHexCode:@"E67E22"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case Eclipse:
            primary = [UIColor colorFromHexCode:@"212A31"];
            secondary = [UIColor colorFromHexCode:@"BA9604"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        case StNick:
            primary = [UIColor colorFromHexCode:@"27AE60"];
            secondary = [UIColor colorFromHexCode:@"C0392B"];
            fontAndTertiary = [UIColor whiteColor];
            shouldUseLightKeyboard = YES;
            
            colors = [[NSArray alloc] initWithObjects:primary, secondary, fontAndTertiary,[NSNumber numberWithBool:shouldUseLightKeyboard] , nil];
            return colors;
            break;
        default:
            NSLog(@"PROBLEMS IN THE COLOR SCHEME MANAGER. GO THERE NOW. BLOOD EVERYWHERE.");
            //If this happens we are going to crash anyways, so might as well do it with meaning
            return  colors;
            break;
    }
}
@end
