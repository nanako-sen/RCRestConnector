//
//  RCDataHandler.h
//  RestConnector
//
//  Created by Anna Walser on 6/13/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCDBManager.h"

@interface RCDataHandler : RCDBManager {
    int cacheRefreshInterval;
}

@property (nonatomic,assign) int cacheRefreshInterval;

+ (id)sharedInstance;
-(BOOL)dataIsUpToDateForClass:(NSString*)className;
- (NSArray*)selectRecordsFromTable:(NSString*)className;
@end
