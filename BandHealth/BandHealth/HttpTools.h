//
//  HttpTools.h
//  BandHealth
//
//  Created by Coofeel on 15/11/30.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface HttpTools : NSObject
+(void)postToURL:(NSString *) url
      withParams:(NSDictionary *)params
        andUseID:(BOOL) userID
     withSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+(void)getURL:(NSString *) url
   withParams:(NSDictionary *)params
     andUseID:(BOOL) userID
  withSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+(void)refreshTokenWithResult:(void (^)(bool success)) result;
@end
