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

//TODO move method into appropriate class
- (BOOL)dataUpToDateForClass:(NSString*)className
{
//    [_DB open];
//    FMResultSet *res = [DB executeQuery:@"SELECT * FROM ? ",className];
//    [_DB close];
    //assuming not up to date
    return false;
}

- (void)insertData:(NSData*)data
{
    
}

@end
