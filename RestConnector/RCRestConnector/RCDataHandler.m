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

@synthesize cacheRefreshInterval = _cacheRefreshInterval, cacheFilterValue = _cacheFilterValue, cacheFilterPropertyName = _cacheFilterPropertyName;


- (BOOL)createTableForClass:(NSString*)className
{
    [self.DB open];
    if (![self tableForClassExists:className]) {
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
           
            if ([self.DB  executeUpdate:qry]) {
                NSLog(@"success");
            }else
                NSLog(@"faild");
            
        } else
            [NSException raise:@"No Table definition" format:@"can't create table because fields not defined"];
        //TODO: is exeption really neccassary? thing of other way to handle this
        
    }
    [self.DB close];
#warning incomplite return logic
    return YES;
}

- (BOOL)tableForClassExists:(NSString*)className
{
    //check if table already exists

    FMResultSet *res = [self.DB  executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name=?;",className];
    [res next];
    BOOL tblExists = [res hasAnotherRow]  ;

    return tblExists;
}

//TODO:check uptodate data by filter eg categoryid
-(BOOL)isDataUpToDateForClass:(NSString*)className
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

- (NSArray*)selectRecordsFromTable:(NSString*)className withQry:(NSString*)qryStr
{

    NSString *qry = nil;

    [self.DB open];
//TODO: clean this mess, make it pretty and not so confusing
    FMResultSet *res;
    if (qryStr == nil){
        NSString *qry;
        if (_cacheFilterPropertyName == NULL || _cacheFilterValue == NULL) {
            qry = [NSString stringWithFormat:@"SELECT * FROM %@",className];
            res = [self.DB executeQuery:qry];
        }else{
            qry = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = ?",className, _cacheFilterPropertyName];
            res = [self.DB executeQuery:qry, _cacheFilterValue];
        }
    }else{
        qry = qryStr;
        res = [self.DB executeQuery:qry];
    }
    
    [self.DB close];
    
    NSArray *objects = [self createObjectArrayFromResult:res forClass:className];
    return objects;
    


    
}

- (NSArray*)createObjectArrayFromResult:(FMResultSet*)res forClass:(NSString*)className
{
    NSMutableArray *objects = [NSMutableArray new];
    NSDictionary *classProps = [RCPropertyClassUtil classPropsFor:[NSClassFromString(className) class]];
    while ([res next])
    {
        id object = [[NSClassFromString(className) alloc] init];
        for (NSString *key in classProps)
        {
            [object setValue:[res objectForColumnName:key] forKey:key];
        }
        
        [objects addObject:object];
    }

    return [objects copy];
}



@end
