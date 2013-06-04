//
//  RCDBInitializer.m
//  RestConnector
//
//  Created by Sen on 5/30/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "RCDBManager.h"
#import "FMDatabase.h"
#import "RCTableUtil.h"

@interface RCDBManager () {

}
-(BOOL)isExecutable:(FMDatabase*)db;
@end

@implementation RCDBManager

@synthesize  path = _path;

- (id)init
{
    if (self = [super init]) {

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
    [self setDatabasePathWithName:@"app.db"];
    FMDatabase *DB = self.database;
    DB.logsErrors = YES;
    DB.traceExecution = YES;
    
    (void)[RCTableUtil createTableIfNotExitsOn:DB forClass:className];
#warning incomplete implementation - return logic missing
    return YES;
}

- (FMDatabase *)database{
    
    FMDatabase *DB = [FMDatabase databaseWithPath:self.path];
    if (![self isExecutable:DB])
        [NSException raise:@"DB could not be opend" format:@"Error with db File"];

    return DB;
}

- (BOOL)isExecutable:(FMDatabase*)db
{
    if (![db open])
        return NO;
    [db close];
    return YES;
}

- (void)setDatabasePathWithName:(NSString*)n
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _path = [documentsDirectory stringByAppendingPathComponent:n];
}


@end
