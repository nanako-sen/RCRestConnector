//
//  RCDBInitializer.h
//  RestConnector
//
//  Created by Sen on 5/30/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;

@interface RCDBManager : NSObject {

    FMDatabase *DB;
}

@property (nonatomic,readonly) FMDatabase *DB;

+ (id)sharedInstance;
- (BOOL)createTableIfNotExitsForClass:(NSString*)className;

- (BOOL)dataUpToDateForClass:(NSString*)className;
- (void)insertData:(NSData*)data;

@end
