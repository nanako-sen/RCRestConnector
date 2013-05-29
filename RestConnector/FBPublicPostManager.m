//
//  UserDataManager.m
//  RestConnector
//
//  Created by Anna Walser on 26/02/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "FBPublicPostManager.h"
#import "FBPublicPost.h"

@implementation FBPublicPostManager


//- (id)createDataStructure:(NSData*)data
//{
//    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
//    NSDictionary *resultDict = [self getJSONObjectsFromData:data];
//    
//    if (resultDict && finalArray) {
//        NSArray *dataArray = [resultDict objectForKey:@"data"];
//        NSDictionary* dict    = nil;
//        NSEnumerator* resultsEnum   = [dataArray objectEnumerator];
//        while (dict = [resultsEnum nextObject])
//        {
//            FBPublicPost *obj = [[FBPublicPost alloc] initWithDictionary:dict];
//            //LLSession* obj = [[LLSession alloc] initWithDictionary:siteData];
//            [finalArray addObject:obj];
//        }
//    }
//    NSArray * arr = [finalArray copy]; //returning NSarray instead of mutable - copy makes an immutable copy
//    return arr;
//}

@end
