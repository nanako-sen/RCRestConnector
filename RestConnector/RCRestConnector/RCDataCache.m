//
//  RCDataCache.m
//  RestConnector
//
//  Created by Anna Walser on 6/13/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCDataCache.h"
#import "RCDataHandler.h"


#define CACHE_REFRESH_INTERVAL 60*60*2
@interface RCDataCache ()
{
    NSString *_className;
    RCDataHandler *_dataHandler;
}

@end

@implementation RCDataCache


@synthesize cacheRefreshInterval = _cacheRefreshInterval, cacheFilterPropertyName = _cacheFilterPropertyName, cacheFilterValue = _cacheFilterValue;

- (id)initWithClass:(NSString*)cN
{    
    if (self = [super init]) {
        _className = cN;
        _dataHandler = [[RCDataHandler alloc] init];
        _dataHandler.cacheRefreshInterval = CACHE_REFRESH_INTERVAL;
    }
    
    return self;
}

- (void)setCacheRefreshInterval:(int)interval
{
    _dataHandler.cacheRefreshInterval = interval;
}

- (void)prepareCache
{
    [_dataHandler createTableForClass:_className];
}

- (BOOL)dataNeedsRefresh
{
    if (self.cacheRefreshInterval == 0)
        return YES;
    else
        return [_dataHandler isDataUpToDateForClass:_className];
}

- (NSArray*)getCachedData
{
    _dataHandler.cacheFilterPropertyName = _cacheFilterPropertyName;
    _dataHandler.cacheFilterValue = _cacheFilterValue;
    return [_dataHandler selectRecordsFromTable:_className withQry:nil];
}
@end
