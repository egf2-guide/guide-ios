//
//  InitController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "InitController.h"

@interface InitController ()

@end

@implementation InitController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.graph.isAuthorized) {
        [self performSegueWithIdentifier:@"ShowTabBar" sender:nil];
    }
    else {
        [self performSegueWithIdentifier:@"ShowLoginScreen" sender:nil];
    }
}
@end
