//
//  RCTableUtil.m
//  RestConnector
//
//  Created by Anna Walser on 6/4/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "RCTableUtil.h"
#import "FMDatabase.h"
#import "RCPropertyClassUtil.h"

@implementation RCTableUtil

+ (BOOL)createTableIfNotExitsOn:(FMDatabase*)DB forClass:(NSString*)className
{
    //check if table already exists
    [DB open];
    FMResultSet *res = [DB executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name='?';",className];
    BOOL tblExists = [res hasAnotherRow]  ;
    [DB close];
    
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
            [DB open];
            if ([DB executeUpdate:qry]) {
                NSLog(@"success");
            }else
                NSLog(@"faild");
            [DB close];
        } else
            [NSException raise:@"No Table definition" format:@"can't create table because fields not defined"];
        //TODO: is exeption really neccassary? thing of other way to handle this
    }
#warning incomplite return logic
    return YES;
}



@end
