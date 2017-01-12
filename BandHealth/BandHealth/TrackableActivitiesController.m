//
//  TrackableActivitiesController.m
//  BandHealth
//
//  Created by Coofeel on 15/11/30.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import "TrackableActivitiesController.h"
#import "TrackableActivityCell.h"
#import "HttpTools.h"
#import "MJRefresh.h"
#import "NSDateComponents+ISO8601Duration.h"
#import <ISO8601/ISO8601.h>
#import "UserInfoTools.h"

@interface TrackableActivitiesController ()
{

    NSString *_nextPage;
    NSMutableArray *_activities;
    NSDateFormatter *_dateFormatter;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TrackableActivitiesController


static NSString *cellid = @"activitycell";


-(void)setup{
    _activities = [NSMutableArray array];
    MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshActivities)];
    refreshHeader.stateLabel.textColor = [UIColor whiteColor];
    refreshHeader.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.header = refreshHeader;
    [self.tableView.header beginRefreshing];
    MJRefreshBackNormalFooter *loadMoreFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreActivies)];
    loadMoreFooter.stateLabel.textColor = [UIColor whiteColor];
    self.tableView.footer = loadMoreFooter;
    [self.tableView setContentInset:UIEdgeInsetsZero];
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.dateFormat = @"yyyy年MM月dd日 HH:mm:ss";
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self.tableView registerNib:[UINib nibWithNibName:@"TrackableActivityCell" bundle:nil] forCellReuseIdentifier:cellid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
}


#pragma mark loadActivitis

-(void)refreshActivities{
    [self getActiviesAndMore:NO];
}

-(void)loadMoreActivies{
    [self getActiviesAndMore:YES];
}

-(void)getActiviesAndMore:(BOOL) more{
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setValue:self.activityType forKey:@"activityTypes"];
    [params setValue:@"10" forKey:@"maxPageSize"];
    
    NSString *url ;
    if(more == YES){
        if(_nextPage && _nextPage.length >0){
            url = _nextPage;
        }else{
            [self.tableView.footer endRefreshing];
            return;
        }
    }
    else{
        [_activities removeAllObjects];
        [self.tableView reloadData];
        url = [NSString stringWithFormat:@"%@/%@/%@",MS_API_HEALTH_HOST,MS_API_HEALTH_VERSION,MS_API_HEALTH_URL_ACTIVITIES];
    }
    
    [HttpTools getURL:url withParams:params andUseID:YES withSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *activiesCache = nil;
        
        if([MS_ACTIVITY_TYPE_RUN isEqual:self.activityType]){
            activiesCache = [responseObject valueForKey:@"runActivities"];
        }
        else if([MS_ACTIVITY_TYPE_BIKE isEqual:self.activityType]){
            activiesCache = [responseObject valueForKey:@"bikeActivities"];
        }
        if(activiesCache && activiesCache.count >0){
            [_activities addObjectsFromArray:activiesCache];
        }
        [weakSelf.tableView reloadData];
        _nextPage = [responseObject valueForKey:@"nextPage"];
        if(more == YES){
            [weakSelf.tableView.footer endRefreshing];
        }else{
            [weakSelf.tableView.header endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(more == YES){
            [weakSelf.tableView.footer endRefreshing];
        }else{
            [weakSelf.tableView.header endRefreshing];
        }
        [KVNProgress showWithStatus:@"重新验证中..."];
        NSInteger statusCode = operation.response.statusCode;
        if(statusCode == 400 || statusCode == 401){
            [HttpTools refreshTokenWithResult:^(bool success) {
                [KVNProgress dismiss];
                if(success == YES){
                    if(more == YES){
                        [weakSelf.tableView.footer beginRefreshing];
                    }else{
                        [weakSelf.tableView.header beginRefreshing];
                    }
                }else{
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    UIViewController *loginCtl = [story instantiateViewControllerWithIdentifier:@"logincontroller"];
                    [weakSelf presentViewController:loginCtl animated:YES completion:nil];
                }
            }];
        }

    }];
}

-(void)getActivityByID:(NSString *) activityID{
    [KVNProgress showWithStatus:@"正在获取活动详情..."];
    __weak typeof(self) weakSelf = self;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@",MS_API_HEALTH_HOST,MS_API_HEALTH_VERSION,MS_API_HEALTH_URL_ACTIVITIES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setValue:activityID forKey:@"activityIds"];
    [params setValue:@"Details,MapPoints" forKey:@"activityIncludes"];
    [params setValue:@"Kilometer" forKey:@"splitDistanceType"];
    [HttpTools getURL:url withParams:params andUseID:YES withSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *activiesCache = nil;
        
        if([MS_ACTIVITY_TYPE_RUN isEqual:self.activityType]){
            activiesCache = [responseObject valueForKey:@"runActivities"];
        }
        else if([MS_ACTIVITY_TYPE_BIKE isEqual:self.activityType]){
            activiesCache = [responseObject valueForKey:@"bikeActivities"];
        }
        if(activiesCache && activiesCache.count >0){
            [weakSelf.tabBarController performSegueWithIdentifier:@"gotomap" sender:[activiesCache objectAtIndex:0]];
        }
        [KVNProgress dismiss];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSInteger statusCode = operation.response.statusCode;
        if(statusCode == 400 || statusCode == 401){
            [KVNProgress showWithStatus:@"重新验证中..."];
            [HttpTools refreshTokenWithResult:^(bool success) {
                [KVNProgress dismiss];
                if(success == YES){
                    [weakSelf getActivityByID:activityID];
                }else{
                    [KVNProgress dismiss];
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    UIViewController *loginCtl = [story instantiateViewControllerWithIdentifier:@"logincontroller"];
                    [weakSelf presentViewController:loginCtl animated:YES completion:nil];
                }
               
            }];
        }
    }];
}



#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *activity = [_activities objectAtIndex:indexPath.row];
    [self getActivityByID:[activity valueForKey:@"id"]];
}

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _activities.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TrackableActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    
    NSDictionary *activity = [_activities objectAtIndex:indexPath.row];
    
    NSDate *startTimeDate = [NSDate dateWithISO8601String:[activity valueForKey:@"startTime"]];
    cell.txtStartTime.text = [_dateFormatter stringFromDate:startTimeDate];
    
    NSString *duration = [activity valueForKey:@"duration"];
    if(duration){
        NSDateComponents *components = [NSDateComponents durationFrom8601String:duration];
        
        NSMutableString *durationString = [NSMutableString new];
        NSInteger hour = components.hour;
        if(hour != NSIntegerMax){
            [durationString appendFormat:@"%d小时",hour];
        }
        NSInteger minute = components.minute;
        if(minute != NSIntegerMax){
            [durationString appendFormat:@"%d分",minute];
        }
        NSInteger second = components.second;
        if(second != NSIntegerMax){
            [durationString appendFormat:@"%d秒",second];
        }
    
        cell.txtDuration.text = durationString;
    }
    
    NSDictionary *distanceSummary = [activity valueForKey:@"distanceSummary"];
    if(distanceSummary){
        NSNumber *distance = [distanceSummary valueForKey:@"totalDistance"];
        if(distance){
            cell.txtDistance.text = [NSString stringWithFormat:@"%0.2f",[distance longValue] / 100000.0f];
        }
    }
    return cell;
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
