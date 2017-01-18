//
//  ListUsersCommand.h
//  RestaurantSearch
//
//  Created by Artur Felipe on 01/07/17.
//  Copyright © 2017 Artur Felipe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ListUsersResponseBlock) (NSDictionary *result, NSError *error);

@interface ListUsersCommand : NSObject

+ (instancetype)sharedInstance;

- (void)listUsersWithBlock:(ListUsersResponseBlock)responseBlock;

@end
