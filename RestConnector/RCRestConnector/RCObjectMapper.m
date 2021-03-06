//
//  RCObjectMapper.m
//  RestConnector
//
//  Created by Anna Walser on 6/5/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCObjectMapper.h"
#import "RCObjectMappingHelper.h"
#import "FMDatabase.h"
#import "RCDBManager.h"

@interface RCDBManager ()
@property (nonatomic,readonly) FMDatabase *DB;
@end

@implementation RCObjectMapper

@synthesize cacheFilterPropertyName = _cacheFilterPropertyName, cacheFilterValue = _cacheFilterValue;

//+ (id)sharedInstance
//{
//    static dispatch_once_t once;
//    static id sharedInstance;
//    dispatch_once(&once, ^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}

//- (id)init
//{
//    if(self = [super init])
//    {
//        
//    }
//    return self;
//}

- (NSArray*)createObjectsFromJSON:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping
{
    //_mappingDictionary = @{@"likes": @{@"likes":@{@"data":@"name"}}, @"postId":@"id", @"name":@{@"from": @"name"}};
    
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    NSDictionary *resultDict = getJSONObjectsFromData(jsonData);
    
    if (resultDict && finalArray) {
        NSDictionary *jsonDict = [resultDict objectForKey:jsonRootKey];
        for (NSDictionary *dict in jsonDict)
        {
            id object = [[NSClassFromString(className) alloc] init];
            
            for(NSString *realKey in [mapping allKeys])
            {
                id mappedValue = [mapping valueForKey: realKey];
                id restValue = getJsonValueByMappedKey(mappedValue,dict);
                
                [object setValue:restValue forKey:realKey];
            }
            [finalArray addObject:object];
        }
    }

    return [finalArray copy];
}


- (NSArray*)insertAndCreateObjectsFromJSON:(NSData*)jsonData
                             onJsonRootKey:(NSString*)jsonRootKey
                                  forClass:(NSString*)className
                     withMappingDictionary:(NSDictionary*)mapping
{
    //_mappingDictionary = @{@"likes": @{@"likes":@{@"data":@"name"}}, @"postId":@"id", @"name":@{@"from": @"name"}};
    
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    NSDictionary *resultDict = getJSONObjectsFromData(jsonData);
    
    if (resultDict && finalArray) {

        NSDictionary *jsonDict = [resultDict objectForKey:jsonRootKey];
        NSMutableArray *objProps;
        NSMutableArray *objPropVals;
        id object;
        
        if ([jsonDict count] != 0) {
            [self.DB open];
            
            NSString *qryDelete;
            BOOL success;
            if (self.cacheFilterPropertyName == NULL && self.cacheFilterValue == NULL) {
                qryDelete = [NSString stringWithFormat:@"DELETE FROM %@",className];
                success = [self.DB executeUpdate:qryDelete];
            }else{
                qryDelete = [NSString stringWithFormat:@"DELETE FROM %@ where %@ = ?",className,self.cacheFilterPropertyName];

                success = [self.DB executeUpdate:qryDelete, self.cacheFilterValue ];
            }
           
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

                [objProps addObject:@"rc_lastUpdated"];
                [objPropVals addObject:[NSDate date]];

                NSString *qry = [NSString stringWithFormat:@"INSERT INTO %@ %@ VALUES (%@)", className, [objProps description], [self getDBBindingSymbol:[objPropVals count]]];
                [self.DB executeUpdate: qry withArgumentsInArray:objPropVals];
                
                [finalArray addObject:object];
            }
            [self.DB close];
        }
    }
    return [finalArray copy];
}

- (NSString*)getDBBindingSymbol:(int)lenth
{
    NSMutableString *sym = [NSMutableString new];
    for (int i = 1; i <= lenth; i++) {
        [sym appendString:@"?,"];
    }
    return  [[sym substringToIndex:[sym length] - 1] copy];
}



@end
