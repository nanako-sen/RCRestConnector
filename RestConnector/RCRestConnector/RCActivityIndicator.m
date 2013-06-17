//
//  RCActivityIndicator.m
//  RestConnector
//
//  Created by Anna Walser on 24/01/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RCActivityIndicator.h"

@implementation RCActivityIndicator

//@synthesize activityView = _activityView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle{
    self = [super initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if(self){
        float sides = 150;
        float scrrenWidth = [UIScreen mainScreen].bounds.size.width;
        float scrrenHeight = [UIScreen mainScreen].bounds.size.height;

        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:14.0f];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"Loading...";
        
        [self addSubview:label];

        self.frame = CGRectMake((scrrenWidth/2) - sides/2, (scrrenHeight/2) - sides/2- 30, sides, sides);
        [self.layer setCornerRadius:5.0];
        self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.6];
        
        
        //adding it to the app just once
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    }
    return self;
}

+ (RCActivityIndicator*)sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithStyle];
    });
    return sharedInstance;

}

- (void)startActivityView
{
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self];
    [self startAnimating];
    [self setHidden:NO];
}

- (void)stopActivityView
{
    if ([self isAnimating]) {
        [self stopAnimating];
        [self setHidden:YES];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
