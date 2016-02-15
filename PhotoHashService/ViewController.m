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

@property (nonatomic) UIButton *runButton;
@property (nonatomic) UIButton *clearButton;
@property (nonatomic) UIButton *getButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _runButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_runButton setTitle:@"Run" forState:UIControlStateNormal];
    [_runButton addTarget:self action:@selector(runService) forControlEvents:UIControlEventTouchUpInside];
    _clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [_clearButton addTarget:self action:@selector(clearService) forControlEvents:UIControlEventTouchUpInside];
    _getButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_getButton setTitle:@"Get" forState:UIControlStateNormal];
    [_getButton addTarget:self action:@selector(getService) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_runButton];
    [self.view addSubview:_clearButton];
    [self.view addSubview:_getButton];
       
    NSLog(@"all: %@", [[PHHashService sharedService] allHashedObjects]);
    
//    NSArray *hashStrings = @[@"5FCC26914F2EB1C7C88614246B45B2CA", @"2E91168C2B18DAE1028BE41F4335ED25", @"E5620A09BC055BA39314D6B9407D4521"];
//    NSLog(@"excluded local identifires: %@", [[PHHashService sharedService] localIdentifiersForHashStrings:hashStrings]);
}

- (void)viewWillLayoutSubviews
{
    [_runButton sizeToFit];
    [_clearButton sizeToFit];
    [_getButton sizeToFit];
    _runButton.center = CGPointMake(self.view.bounds.size.width/2 - 40, self.view.bounds.size.height/2);
    _clearButton.center = CGPointMake(self.view.bounds.size.width/2 + 40, self.view.bounds.size.height/2);
    _getButton.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 + 40);
}

- (void)runService
{
    [[PHHashService sharedService] run];
}

- (void)clearService
{
    [[PHHashService sharedService] clear];
}

- (void)getService
{
    NSLog(@"%@", [[PHHashService sharedService] allHashedObjects]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
