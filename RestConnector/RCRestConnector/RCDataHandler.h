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
    NSString *cacheFilterPropertyName;
    id cacheFilterValue;
}

@property (nonatomic,assign) int cacheRefreshInterval;
@property (nonatomic, retain) NSString *cacheFilterPropertyName;
@property (nonatomic, retain) id cacheFilterValue;



- (BOOL)createTableForClass:(NSString*)className;
- (BOOL)isDataUpToDateForClass:(NSString*)className;
//- (NSArray*)selectRecordsFromTable:(NSString*)className;
- (NSArray*)selectRecordsFromTable:(NSString*)className withQry:(NSString*)qryStr;
@end
