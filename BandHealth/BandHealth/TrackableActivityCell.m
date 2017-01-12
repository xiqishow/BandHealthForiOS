//
//  TrackableActivityCell.m
//  BandHealth
//
//  Created by Coofeel on 15/11/30.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import "TrackableActivityCell.h"

@implementation TrackableActivityCell

- (void)awakeFromNib {
    // Initialization code
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *selecedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    [selecedBackgroundView setBackgroundColor:[UIColor colorWithRed:21.0f/225.0f green:104.0f/255.0f blue:169.0f/255.0f alpha:1.0]];
    self.selectedBackgroundView = selecedBackgroundView;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
