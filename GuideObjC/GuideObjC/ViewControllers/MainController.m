//
//  MainController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "MainController.h"
#import "InitController.h"

@interface MainController ()

@end

@implementation MainController

- (InitController *)controller {
    if ([self.navigationController isMemberOfClass:[InitController class]]) {
        return (InitController *)self.navigationController;
    }
    return nil;
}

- (IBAction)logout:(id)sender {
    [self.graph logoutWithCompletion:^(id object, NSError * error) {
        [[self controller] performSegueWithIdentifier:@"ShowLoginScreen" sender:nil];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.graph.isAuthorized) {
        [self controller].viewControllers = @[];
    }
}
@end
