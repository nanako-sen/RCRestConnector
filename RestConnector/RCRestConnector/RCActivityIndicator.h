//
//  RCActivityIndicator.h
//  RestConnector
//
//  Created by Anna Walser on 24/01/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCActivityIndicator : UIActivityIndicatorView{
    //UIActivityIndicatorView *activityView;
}
//@property (nonatomic, retain) UIActivityIndicatorView *activityView;

+ (RCActivityIndicator*)sharedInstance;

- (void)startActivityView;
- (void)stopActivityView;
@end
