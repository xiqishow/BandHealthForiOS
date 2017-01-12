//
//  MapPointAnnotation.h
//  BandHealth
//
//  Created by Coofeel on 15/12/3.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

typedef enum : NSUInteger {
    PointTypeStart,
    PointTypeEnd,
    PointTypeSlipt,
} PointType;

@interface MapPointAnnotation : BMKPointAnnotation

@property(nonatomic) PointType pointType;

@end
