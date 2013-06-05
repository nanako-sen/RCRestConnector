//
//  RCTableUtil.h
//  RestConnector
//
//  Created by Anna Walser on 6/4/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;

@interface RCTableCreator : NSObject
+ (BOOL)createTableIfNotExitsOn:(FMDatabase*)DB forClass:(NSString*)className;
@end
