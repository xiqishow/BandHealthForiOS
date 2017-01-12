//
//  HttpTools.m
//  BandHealth
//
//  Created by Coofeel on 15/11/30.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import "HttpTools.h"


@implementation HttpTools


+(void)postToURL:(NSString *) url
      withParams:(NSDictionary *)params
        andUseID:(BOOL) userID
     withSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    if(params && params.count >0){
        [postParams addEntriesFromDictionary:params];
    }
    if(userID == YES){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults valueForKey:@"ms_token"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",token] forHTTPHeaderField:@"Authorization"];
    }
    [manager POST:url parameters:params success: success failure: failure];
}

+(void)getURL:(NSString *) url
      withParams:(NSDictionary *)params
        andUseID:(BOOL) userID
     withSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    if(params && params.count >0){
        [postParams addEntriesFromDictionary:params];
    }
    if(userID == YES){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults valueForKey:MS_APP_LOCAL_TOKEN];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",token] forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:url parameters:params success: success failure: failure];
}


+(void)refreshTokenWithResult:(void (^)(bool success)) result{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:MS_CLIENTID forKey:@"client_id"];
    [params setValue:MS_APPSECRET forKey:@"client_secret"];
    [params setValue:MS_APP_RESULT_REDIRECT forKey:@"redirect_uri"];
    [params setValue:[[NSUserDefaults standardUserDefaults] valueForKey:MS_APP_LOCAL_REFRESHTOKEN] forKey:@"refresh_token"];
    [params setValue:@"refresh_token" forKey:@"grant_type"];
    [HttpTools getURL:MS_APP_TOKEN_URL withParams:params andUseID:NO withSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:[responseObject valueForKey:@"access_token"] forKey:MS_APP_LOCAL_TOKEN];
        [userDefaults setValue:[responseObject valueForKey:@"refresh_token"] forKey:MS_APP_LOCAL_REFRESHTOKEN];
        [userDefaults synchronize];
        if(result)
        result(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(result)
        result(NO);
    }];
}

@end
