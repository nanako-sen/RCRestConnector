//
//  RCDBInitializer.m
//  RestConnector
//
//  Created by Sen on 5/30/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "RCDBManager.h"
#import "FMDatabase.h"
#import "RCTableCreator.h"
#import "RCPropertyClassUtil.h"

@interface RCDBManager () {

}
-(BOOL)isExecutable:(FMDatabase*)db;
- (NSString*)databasePathWithName:(NSString*)n;
@end

@implementation RCDBManager

@synthesize  DB = _DB;

- (id)init
{
    if (self = [super init]) {
        _DB = self.DB;
    }
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)createTableIfNotExitsForClass:(NSString*)className
{
//TODo: logic around db file (db file has to be in document folder)
    
    //FMDatabase *DB = _DB;
    (void)[RCTableCreator createTableIfNotExitsOn:_DB forClass:className];
#warning incomplete implementation - return logic missing
    return YES;
}

- (FMDatabase *)DB
{ 
    NSString *path = [self databasePathWithName:@"app.db"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    database.logsErrors = YES;
    database.traceExecution = YES;
    if (![self isExecutable:database])
        [NSException raise:@"DB could not be opend" format:@"Error with db File"];

    return database;
}

- (BOOL)isExecutable:(FMDatabase*)db
{
    if (![db open])
        return NO;
    [db close];
    return YES;
}

- (NSString*)databasePathWithName:(NSString*)n
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:n];
}

#pragma mark tabledata methods

//TODO move ALL following methods into appropriate class
//TODO set constant name for data column
- (BOOL)dataUpToDateForClass:(NSString*)className
{
    NSDate *upDated;
    [_DB open];
    NSString *qry = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 1",className];
    FMResultSet *res = [_DB executeQuery:qry];
    while ([res next]) {
        upDated = [NSDate dateWithTimeIntervalSince1970:[res doubleForColumn:@"rc_lastUpdated"]];
    }
    [_DB close];
    NSComparisonResult result = [[NSDate dateWithTimeInterval:60*60*2 sinceDate:upDated] compare:[NSDate date]];
    
    return (result == NSOrderedSame || result == NSOrderedAscending) ? NO : YES;

}

- (NSArray*)selectRecordsFromTable:(NSString*)className
{
    NSMutableArray *objects = [NSMutableArray new];
    
    NSDictionary *classProps = [RCPropertyClassUtil classPropsFor:[NSClassFromString(className) class]];
    [_DB open];
    NSString *qry = [NSString stringWithFormat:@"SELECT * FROM %@",className];
    FMResultSet *res = [_DB executeQuery:qry];
    while ([res next])
    {
        id object = [[NSClassFromString(className) alloc] init];
        for (NSString *key in classProps)
        {
            [object setValue:[res objectForColumnName:key] forKey:key];
        }

        [objects addObject:object];
    }
    [_DB close];
    return [objects copy];
}

- (void)insertData:(NSData*)data
{
    
}

@end
