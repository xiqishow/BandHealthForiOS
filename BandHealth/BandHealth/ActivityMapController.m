//
//  ActivityMapController.m
//  BandHealth
//
//  Created by Coofeel on 15/12/2.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import "ActivityMapController.h"
#import "NSDateComponents+ISO8601Duration.h"
#import <ISO8601/ISO8601.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "MapPointAnnotation.h"

@interface ActivityMapController ()
{
    BMKMapRect visibleRect;
    BOOL isFirtDisappear;
    __weak IBOutlet UIView *infoView;
    
    UIBarButtonItem *leftItem;
    UIBarButtonItem *rightItem;
    
}
@property (weak, nonatomic) IBOutlet UILabel *txtDistance;

@property (weak, nonatomic) IBOutlet UILabel *txtDuration;

@property (weak, nonatomic) IBOutlet UILabel *txtHeartrate;

@property (weak, nonatomic) IBOutlet UILabel *txtCalories;

@property (weak, nonatomic) IBOutlet UILabel *txtStartTime;

@property (weak, nonatomic) IBOutlet BMKMapView *mapView;

@end

@implementation ActivityMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fillActivityData];
    
    leftItem = self.navigationItem.leftBarButtonItem;
    rightItem = self.navigationItem.rightBarButtonItem;
}

-(void)fillActivityData{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy年MM月dd日 HH:mm:ss";
    NSDate *startTimeDate = [NSDate dateWithISO8601String:[_activity valueForKey:@"startTime"]];
    self.txtStartTime.text = [dateFormatter stringFromDate:startTimeDate];
    
    NSString *duration = [_activity valueForKey:@"duration"];
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
        self.txtDuration.text = durationString;
    }
    
    NSDictionary *distanceSummary = [_activity valueForKey:@"distanceSummary"];
    if(distanceSummary){
        NSNumber *distance = [distanceSummary valueForKey:@"totalDistance"];
        if(distance){
            self.txtDistance.text = [NSString stringWithFormat:@"%0.2f公里",[distance longValue] / 100000.0f];
        }
    }
    
    NSDictionary *caloriesBurnedSummary = [_activity valueForKey:@"caloriesBurnedSummary"];
    if(caloriesBurnedSummary){
        NSNumber *totalCalories = [caloriesBurnedSummary valueForKey:@"totalCalories"];
        self.txtCalories.text = [NSString stringWithFormat:@"%d卡",[totalCalories intValue]];
    }
    
    NSDictionary *heartRateSummary = [_activity valueForKey:@"heartRateSummary"];
    if(heartRateSummary){
        NSNumber *averageHeartRate = [heartRateSummary valueForKey:@"averageHeartRate"];
        self.txtHeartrate.text = [averageHeartRate stringValue];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    if(isFirtDisappear == NO){
        isFirtDisappear = YES;
        [self setupActivityMap];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didBtnShotTapped:(id)sender {
    
  
//    self.navigationItem.leftBarButtonItem = nil;
//    self.navigationItem.rightBarButtonItem = nil;
    self.navigationController.navigationBarHidden = YES;
    UIImage *screenShot = [self snapshot];
//    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBarHidden = NO;
    
    UIImageWriteToSavedPhotosAlbum(screenShot, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    [UIView beginAnimations:@"shot" context:nil];
    [UIView setAnimationDelay:2];
    infoView.alpha = 0.5;
    [UIView commitAnimations];
    [UIView beginAnimations:@"shot" context:nil];
    [UIView setAnimationDelay:2];
    infoView.alpha = 1.0;
    [UIView commitAnimations];

  
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    
}

-(UIImage *)snapshot {
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)snapshotView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]); //0
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}



#pragma mark - ActivityMap
-(void)setupActivityMap{
    
    NSMutableArray *filteredMappoints = [NSMutableArray array];
    
    NSArray *mapPoints = [self.activity valueForKey:@"mapPoints"];
    
    for (NSDictionary *mapPoint in mapPoints) {
        NSDictionary *location = [mapPoint valueForKey:@"location"];
        if(location){
            [filteredMappoints addObject:mapPoint];
        }
    }
    
    CLLocationCoordinate2D startPoint = CLLocationCoordinate2DMake(360.0, 360.0);
    CLLocationCoordinate2D endPoint = CLLocationCoordinate2DMake(360.0, 360.0);
    
    if(filteredMappoints.count > 0){
        int sliptIndex = 1;
        CLLocationCoordinate2D *coordinates = malloc([filteredMappoints count] * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < filteredMappoints.count; i++) {
            NSDictionary *mapPoint = [filteredMappoints objectAtIndex:i];
            NSDictionary *location = [mapPoint valueForKey:@"location"];
            double latitude = [[location valueForKey:@"latitude"] doubleValue] / 10000000.0;
            double longitude = [[location valueForKey:@"longitude"] doubleValue] / 10000000.0;
            NSDictionary* convertDic = BMKConvertBaiduCoorFrom(CLLocationCoordinate2DMake(latitude, longitude),BMK_COORDTYPE_GPS);
            CLLocationCoordinate2D coordinate = BMKCoorDictionaryDecode(convertDic);
            coordinates[i] = coordinate;
            NSString *pointType = [mapPoint valueForKey:@"mapPointType"];
            if([@"Start" isEqual:pointType]){
                startPoint = coordinate;
            }
            else if([@"End" isEqual:pointType]){
                endPoint = coordinate;
            }
            else if([@"Split" isEqual:pointType]){
                MapPointAnnotation *sliptAnnotation = [[MapPointAnnotation alloc] init];
                sliptAnnotation.coordinate = coordinate;
                sliptAnnotation.title = [NSString stringWithFormat:@"%d",sliptIndex];
                sliptAnnotation.pointType = PointTypeSlipt;
                [_mapView addAnnotation:sliptAnnotation];
                sliptIndex++;
            }
        }
        
        if(CLLocationCoordinate2DIsValid(startPoint) == NO){
            startPoint = coordinates[0];
        }
        if(CLLocationCoordinate2DIsValid(endPoint) == NO){
            endPoint = coordinates[filteredMappoints.count - 1];
        }
        
        BMKPolyline* trackLine = [BMKPolyline polylineWithCoordinates:coordinates count:filteredMappoints.count];
        [_mapView addOverlay:trackLine];
        visibleRect = trackLine.boundingMapRect;
        
        MapPointAnnotation *startAnnotation = [[MapPointAnnotation alloc]init];
        startAnnotation.coordinate = startPoint;
        startAnnotation.title = @"起";
        startAnnotation.pointType = PointTypeStart;
        [_mapView addAnnotation:startAnnotation];
        
        MapPointAnnotation *endAnnotation = [[MapPointAnnotation alloc] init];
        endAnnotation.coordinate = endPoint;
        endAnnotation.title = @"终";
        endAnnotation.pointType = PointTypeEnd;
        [_mapView addAnnotation:endAnnotation];
        

        free(coordinates);
    }
}

- (UIImage*)imageForSlipt:(NSString*)string {
    // set rect, size, font
    CGRect rect = CGRectMake(0, 0, 20, 20);
    CGSize size = CGSizeMake(rect.size.width, rect.size.height);
    // retina display, double resolution
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    UIImage *image = [UIImage imageNamed:@"map_point_slipt"];
    [image drawAtPoint:CGPointMake(0, 0)];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[UIFont fontWithName:@"Helvetica" size:6] forKey:NSFontAttributeName];
    [attributes setObject:[NSNumber numberWithFloat:10] forKey:NSStrokeWidthAttributeName];
    [attributes setObject:[UIColor blackColor] forKey:NSStrokeColorAttributeName];
    // draw stroke
    CGSize fontSize = [string sizeWithAttributes:attributes];
    [string drawAtPoint:CGPointMake((rect.size.width - fontSize.width) / 2, (rect.size.height - fontSize.height)/2) withAttributes:attributes];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - BMKMapViewDelegate


- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    visibleRect.origin.y = visibleRect.origin.y - 100;
    visibleRect.origin.x = visibleRect.origin.x - 100;
    visibleRect.size.height = visibleRect.size.height+200;
    visibleRect.size.width = visibleRect.size.width +200;
    [_mapView setVisibleMapRect:visibleRect];
}

-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* trackLineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        trackLineView.strokeColor = [THEME_BLUE colorWithAlphaComponent:0.6f];
        trackLineView.lineWidth = 4.0;
        return trackLineView;
    }
    
    return nil;
}

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if([annotation isKindOfClass:[MapPointAnnotation class]]){
        
        MapPointAnnotation *mapAnnotation = (MapPointAnnotation *)annotation;
        
        BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"mappoint"];
        if(annotationView == nil){
            annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"mappoint"];
        }
        
        switch (mapAnnotation.pointType) {
            case PointTypeStart:
                annotationView.image = [UIImage imageNamed:@"map_point_start"];
                break;
            case PointTypeEnd:
                annotationView.image = [UIImage imageNamed:@"map_point_end"];
                break;
            case PointTypeSlipt:
                annotationView.image = [self imageForSlipt
                                        :annotation.title];
//                annotationView.image = [self addText:[UIImage imageNamed:@"map_point_slipt"] text:annotation.title];
                break;
            default:
                return nil;
        }
        return annotationView;
    }
    return nil;
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
