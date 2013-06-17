//
//  RCDBInitializer.m
//  RestConnector
//
//  Created by Anna Walser on 5/30/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCDBManager.h"
#import "FMDatabase.h"
#import "RCTableCreator.h"
#import "RCPropertyClassUtil.h"

@interface RCDBManager () {
    FMDatabase *DB;
}
@property (nonatomic,readonly) FMDatabase *DB;

-(BOOL)isExecutable:(FMDatabase*)db;
- (NSString*)databasePathWithName:(NSString*)n;
@end

@implementation RCDBManager

@synthesize  DB = _DB;

- (id)init
{
    if(self = [super init]){
        
    }
    return self;
}

- (FMDatabase *)DB
{ 
    if(!_DB) {
        NSString *path = [self databasePathWithName:@"app.db"];
        _DB = [FMDatabase databaseWithPath:path];
        _DB.logsErrors = YES;
        _DB.traceExecution = YES;
        if (![self isExecutable:_DB])
            [NSException raise:@"DB could not be opend" format:@"Error with db File"];
    }
    return _DB;
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

@end
