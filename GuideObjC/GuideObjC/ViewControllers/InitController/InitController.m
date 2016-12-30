//
//  InitController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "InitController.h"
#import "OffensivePosts.h"
#import "Follows.h"

@interface InitController ()

@end

@implementation InitController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.graph.isAuthorized) {
        [[Follows shared] startObserving];
        [[OffensivePosts shared] startSession];
        [self performSegueWithIdentifier:@"ShowTabBar" sender:nil];
    }
    else {
        [self performSegueWithIdentifier:@"ShowLoginScreen" sender:nil];
    }
}
@end
