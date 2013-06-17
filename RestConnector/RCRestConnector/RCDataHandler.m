//
//  RCDataHandler.m
//  RestConnector
//
//  Created by Anna Walser on 6/13/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCDataHandler.h"
#import "FMResultSet.h"
#import "FMDatabase.h"
#import "RCPropertyClassUtil.h"

@interface RCDBManager ()
@property (nonatomic,readonly) FMDatabase *DB;
@end

@implementation RCDataHandler

@synthesize cacheRefreshInterval = _cacheRefreshInterval;


+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(BOOL)dataIsUpToDateForClass:(NSString*)className
{
    NSDate *upDated;
    [self.DB open];
    NSString *qry = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 1",className];
    FMResultSet *res = [self.DB executeQuery:qry];
    while ([res next]) {
        upDated = [NSDate dateWithTimeIntervalSince1970:[res doubleForColumn:@"rc_lastUpdated"]];
    }
    [self.DB close];
    NSComparisonResult result = [[NSDate dateWithTimeInterval:self.cacheRefreshInterval sinceDate:upDated] compare:[NSDate date]];
    
    return (result == NSOrderedSame || result == NSOrderedAscending) ? NO : YES;
    
}

- (NSArray*)selectRecordsFromTable:(NSString*)className
{
    NSMutableArray *objects = [NSMutableArray new];
    
    NSDictionary *classProps = [RCPropertyClassUtil classPropsFor:[NSClassFromString(className) class]];
    [self.DB open];
    NSString *qry = [NSString stringWithFormat:@"SELECT * FROM %@",className];
    FMResultSet *res = [self.DB executeQuery:qry];
    while ([res next])
    {
        id object = [[NSClassFromString(className) alloc] init];
        for (NSString *key in classProps)
        {
            [object setValue:[res objectForColumnName:key] forKey:key];
        }
        
        [objects addObject:object];
    }
    [self.DB close];
    return [objects copy];
}
@end
