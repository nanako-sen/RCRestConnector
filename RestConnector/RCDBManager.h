//
//  RCDBInitializer.h
//  RestConnector
//
//  Created by Sen on 5/30/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;

@interface RCDBManager : NSObject

@property (nonatomic,readonly) NSString *path;
@property (nonatomic,readonly) FMDatabase *database;

+ (id)sharedInstance;
- (BOOL)createTableIfNotExitsForClass:(NSString*)className;
- (void)setDatabasePathWithName:(NSString*)n;

@end
