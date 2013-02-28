//
//  UserDataManager.h
//  RestConnector
//
//  Created by Anna Walser on 26/02/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "RCDataManager.h"

@interface FBPublicPostManager : RCDataManager
- (id)initWithDelegate:(id<DataManagerDelegate>)theDelegate;
- (void)getFacebookPeople;
@end
