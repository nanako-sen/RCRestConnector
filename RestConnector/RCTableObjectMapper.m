//
//  RCTableObjectMapper.m
//  RestConnector
//
//  Created by Anna Walser on 6/6/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "RCTableObjectMapper.h"
#import "RCObjectMappingHelper.h"
#import "FMDatabase.h"
#import "RCPropertyClassUtil.h"

@implementation RCTableObjectMapper

+ (NSSet*)insertAndGetObjectsFromJSON:(FMDatabase*)DB json:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
                       forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping
{
    //_mappingDictionary = @{@"likes": @{@"likes":@{@"data":@"name"}}, @"postId":@"id", @"name":@{@"from": @"name"}};
    
    NSMutableSet *finalArray = [[NSMutableSet alloc] init];
    NSDictionary *resultDict = getJSONObjectsFromData(jsonData);
 
    if (resultDict && finalArray) {
        [DB open];
        NSDictionary *jsonDict = [resultDict objectForKey:jsonRootKey];
        NSMutableArray *objProps;
        NSMutableArray *objPropVals;
        id object;
        for (NSDictionary *dict in jsonDict)
        {
            object = [[NSClassFromString(className) alloc] init];
            objProps= [NSMutableArray new];
            objPropVals = [NSMutableArray new];
            
            for(NSString *realKey in [mapping allKeys])
            {
                id mappedValue = [mapping valueForKey: realKey];
                id restValue = getJsonValueByMappedKey(mappedValue,dict);
                
                [object setValue:restValue forKey:realKey];
                [objProps addObject:realKey];
                [objPropVals addObject:restValue];
            }
            //iserting object data into db
            [objProps addObject:@"rc_lastUpdated"];
            [objPropVals addObject:[NSDate date]];
            NSString *qry = [NSString stringWithFormat:@"INSERT INTO %@ %@ VALUES (%@)", className, [objProps description], [self getDBBindingSymbol:[objPropVals count]]];
            [DB executeUpdate: qry withArgumentsInArray:objPropVals];

            [finalArray addObject:object];
        }
//        qry = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", className, @"rc_lastUpdated"];
//        [DB executeUpdate:qry,[NSDate date]];
        [DB close];
    }
    NSSet * arr = [finalArray copy]; //returning NSarray instead of mutable - copy makes an immutable copy
    return arr;
}

+ (NSString*)getDBBindingSymbol:(int)lenth
{
    NSMutableString *sym = [NSMutableString new];
    for (int i = 1; i <= lenth; i++) {
        [sym appendString:@"?,"];
    }
    return  [[sym substringToIndex:[sym length] - 1] copy];
}

@end
