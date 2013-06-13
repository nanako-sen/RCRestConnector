//
//  RCTableUtil.m
//  RestConnector
//
//  Created by Anna Walser on 6/4/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCTableCreator.h"
#import "FMDatabase.h"
#import "RCPropertyClassUtil.h"

@interface RCDBManager ()
@property (nonatomic,readonly) FMDatabase *DB;
@end

@interface RCTableCreator ()

@end

@implementation RCTableCreator

+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)createTableIfNotExits:(NSString*)className
{
    //check if table already exists
    [self.DB open];
    FMResultSet *res = [self.DB  executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name=?;",className];
    [res next];
    BOOL tblExists = [res hasAnotherRow]  ;
    [self.DB  close];
    
    if (!tblExists) {
        NSDictionary* classProperties= [RCPropertyClassUtil classPropsFor:[NSClassFromString(className) class]];
        NSLog(@"creating table from object of dictionary: %@", classProperties);
        //building table fileds
        NSMutableString *tbFields = [NSMutableString stringWithCapacity:100];;
        for (NSString* key in classProperties)
        {
            NSString *field= [NSString stringWithFormat:@"%@ %@,", key, [classProperties objectForKey:key]];
            [tbFields appendString:field];
        }
        
        if ([tbFields length] > 0) {
            [tbFields appendString:@"rc_lastUpdated numeric"];
            //NSString *tbFields = [tbFieldsRaw substringFromIndex:[tbFieldsRaw length] -1 ];//stripping last comma
            NSLog(@"creating db with fields:%@",tbFields);
            NSString *qry = [NSString stringWithFormat:@"create table %@ (%@)",className,tbFields];
            [self.DB open];
            if ([self.DB  executeUpdate:qry]) {
                NSLog(@"success");
            }else
                NSLog(@"faild");
            [self.DB close];
        } else
            [NSException raise:@"No Table definition" format:@"can't create table because fields not defined"];
        //TODO: is exeption really neccassary? thing of other way to handle this
    }
#warning incomplite return logic
    return YES;
}



@end
