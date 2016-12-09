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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.graph.isAuthorized && self.viewControllers.count == 0) {
        UIViewController * mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"Main"];
        self.viewControllers = @[mainController];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.graph.isAuthorized) {
        [self performSegueWithIdentifier:@"ShowLoginScreen" sender:nil];
    }
}
@end
