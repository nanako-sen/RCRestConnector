//
//  RCTableUtil.h
//  RestConnector
//
//  Created by Anna Walser on 6/4/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//


#import "RCDBManager.h"

@interface RCTableCreator : RCDBManager
+ (id)sharedInstance;
- (BOOL)createTableIfNotExits:(NSString*)className;
@end
