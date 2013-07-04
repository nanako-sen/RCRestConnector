//
//  RCDataCache.h
//  RestConnector
//
//  Created by Anna Walser on 6/13/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDataCache : NSObject
{
    int cacheRefreshInterval;
    NSString *cacheFilterPropertyName;
    id cacheFilterValue;
}

@property (nonatomic,assign) int cacheRefreshInterval;
@property (nonatomic, retain) NSString *cacheFilterPropertyName;
@property (nonatomic, retain) id cacheFilterValue;

- (id)initWithClass:(NSString*)cN;
- (void)prepareCache;
- (BOOL)dataNeedsRefresh;
- (NSArray*)getCachedData;
@end
