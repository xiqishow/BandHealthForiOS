//
//  UserInfoTools.m
//  BandHealth
//
//  Created by Coofeel on 15/12/7.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import "UserInfoTools.h"

@implementation UserInfoTools


+(void)showLoginInController:(UIViewController *)controller {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *loginCtl = [story instantiateViewControllerWithIdentifier:@"logincontroller"];
    [controller presentViewController:loginCtl animated:YES completion:nil];
}

@end
