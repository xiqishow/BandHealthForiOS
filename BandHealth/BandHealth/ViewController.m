//
//  ViewController.m
//  BandHealth
//
//  Created by Coofeel on 15/11/30.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UI Event

- (IBAction)didBtnLoginTapped:(id)sender {
    [self performSegueWithIdentifier:@"gotologin" sender:nil];
}


- (IBAction)didBtnActivitiesTapped:(id)sender {
    [self performSegueWithIdentifier:@"gotoactivities" sender:nil];
}



@end
