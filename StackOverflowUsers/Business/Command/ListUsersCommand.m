//
//  ListUsersCommand.m
//  RestaurantSearch
//
//  Created by Artur Felipe on 01/07/17.
//  Copyright © 2017 Artur Felipe. All rights reserved.
//

#import "ListUsersCommand.h"

@interface ListUsersCommand () {
    
}

@end

@implementation ListUsersCommand

+ (instancetype)sharedInstance
{
    static ListUsersCommand *instance = nil;
    static dispatch_once_t onceToken;
    
    if (instance) return instance;
    
    dispatch_once(&onceToken, ^{
        instance = [ListUsersCommand alloc];
        instance = [instance init];
    });
    
    return instance;
}

- (void)dealloc {
    
}

- (void)listUsersWithBlock:(ListUsersResponseBlock)responseBlock{
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create([[NSString stringWithFormat:@"StackOverflowUsers.%@", NSStringFromClass([self class])] UTF8String], NULL);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(backgroundQueue, ^
                   {
                       NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.stackexchange.com/2.2/users?site=stackoverflow"]];
                       
                       NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
                       request.HTTPMethod = @"GET";
                       
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                           if (error) {
                               if (error) {
                                   dispatch_async(mainQueue, ^
                                                  {
                                                      if (responseBlock) responseBlock(nil, error);
                                                  });
                               }
                           } else {
                               NSError *jsonError;
                               NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                               NSLog(@"%@", jsonDictionary);
                               
                               NSArray *results = [jsonDictionary objectForKey:@"items"];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   NSMutableArray *aMutableArray = [[NSMutableArray alloc] init];
                                   
                                   if(results.count > 0){
                                       for (NSDictionary *result in results) {
                                           [aMutableArray addObject:result];
                                       }
                                   }
                                   
                                   dispatch_async(mainQueue, ^
                                                  {
                                                      if (responseBlock) responseBlock(@{@"result": [aMutableArray copy]}, error);
                                                  });
                               });
                           }
                       }]
                        resume];
                   });
    
}

@end
