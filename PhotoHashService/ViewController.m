//
//  ViewController.m
//  PhotoHashService
//
//  Created by naru on 2016/02/14.
//  Copyright © 2016年 naru. All rights reserved.
//

@import Photos;
#import "ViewController.h"
#import "PHHashService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [[PHHashService sharedService] clear];
    
    [[PHHashService sharedService] run];
       
    NSLog(@"all: %@", [[PHHashService sharedService] allHashedObjects]);
    
//    NSArray *hashStrings = @[@"5FCC26914F2EB1C7C88614246B45B2CA", @"2E91168C2B18DAE1028BE41F4335ED25", @"E5620A09BC055BA39314D6B9407D4521"];
//    NSLog(@"excluded local identifires: %@", [[PHHashService sharedService] localIdentifiersForHashStrings:hashStrings]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
