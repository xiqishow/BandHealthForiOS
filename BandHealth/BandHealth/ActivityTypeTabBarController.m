//
//  ActivityTypeTabBarController.m
//  BandHealth
//
//  Created by Coofeel on 15/12/1.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import "ActivityTypeTabBarController.h"
#import "TrackableActivitiesController.h"
#import "ActivityMapController.h"
#import "UserInfoTools.h"

@interface ActivityTypeTabBarController ()

@end

@implementation ActivityTypeTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *refresh_token = [[NSUserDefaults standardUserDefaults] valueForKey:MS_APP_LOCAL_REFRESHTOKEN];
    if(refresh_token == nil){
        [UserInfoTools showLoginInController:self];
    }

    // Do any additional setup after loading the view.
    NSArray<TrackableActivitiesController*> *childControllers = self.childViewControllers;
    childControllers[0].activityType = @"Run";
    childControllers[1].activityType = @"Bike";
    self.tabBar.selectedImageTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor whiteColor];
    
    
}

- (IBAction)didBtnClearTokenTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setValue: @"123" forKey:MS_APP_LOCAL_TOKEN];
    [defaults setValue:@"321" forKey:MS_APP_LOCAL_REFRESHTOKEN];
    [defaults synchronize];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([@"gotomap" isEqual:segue.identifier]){
        ActivityMapController *mapCtl = segue.destinationViewController;
        NSDictionary *activity = sender;
        [mapCtl setActivity:activity];
    }
}


#pragma mark UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
