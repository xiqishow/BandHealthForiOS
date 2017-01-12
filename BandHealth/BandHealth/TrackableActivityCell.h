//
//  TrackableActivityCell.h
//  BandHealth
//
//  Created by Coofeel on 15/11/30.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackableActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *txtDuration;
@property (weak, nonatomic) IBOutlet UILabel *txtStartTime;
@property (weak, nonatomic) IBOutlet UILabel *txtDistance;

@end
