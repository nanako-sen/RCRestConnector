//
//  RCDataCache.m
//  RestConnector
//
//  Created by Anna Walser on 6/13/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCDataCache.h"
#import "RCTableCreator.h"
#import "RCDataHandler.h"


#define CACHE_REFRESH_INTERVAL 60*60*2
@interface RCDataCache ()
{
    NSString *_className;
    RCDataHandler *_dataHandler;
}

@end

@implementation RCDataCache


@synthesize cacheRefreshInterval = _cacheRefreshInterval;

- (id)initWithClass:(NSString*)cN
{    
    if (self = [super init]) {
        _className = cN;
        _dataHandler = [RCDataHandler sharedInstance];
        _dataHandler.cacheRefreshInterval = 60*60*2;
    }
    
    return self;
}

- (void)setCacheRefreshInterval:(int)interval
{
    _dataHandler.cacheRefreshInterval = interval;
}

- (void)prepareCache
{
    RCTableCreator *tC = [RCTableCreator sharedInstance];
    [tC createTableIfNotExits:_className];
}

- (BOOL)dataNeedsRefresh
{
    return [_dataHandler dataIsUpToDateForClass:_className];
}

- (NSArray*)getCachedData
{
    return [_dataHandler selectRecordsFromTable:_className withQry:nil];
}
@end
