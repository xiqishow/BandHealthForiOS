//
//  ActivityMapController.h
//  BandHealth
//
//  Created by Coofeel on 15/12/2.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface ActivityMapController : UIViewController<BMKMapViewDelegate>

@property (nonatomic,strong) NSDictionary *activity;

@end
