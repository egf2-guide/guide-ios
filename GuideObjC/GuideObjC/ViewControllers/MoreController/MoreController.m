//
//  MoreController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "MoreController.h"
#import "InitController.h"

@interface MoreController ()

@end

@implementation MoreController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0.1)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.title = @"More";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (![cell.reuseIdentifier isEqual:@"LogoutCell"]) {
        return;
    }
    if ([self.navigationController isMemberOfClass:[InitController class]]) {
        [self.graph logoutWithCompletion:^(id object, NSError * error) {
            [self.navigationController performSegueWithIdentifier:@"ShowLoginScreen" sender:nil];
        }];
    }
}
@end
