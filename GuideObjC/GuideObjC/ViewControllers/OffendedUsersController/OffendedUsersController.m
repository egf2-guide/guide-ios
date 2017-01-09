//
//  OffendedUsersController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

#import "OffendedUsersController.h"
#import "UserProfileController.h"
#import "OffendedUserCell.h"
#import "EdgeDownloader.h"
#import "ProgressCell.h"

@interface OffendedUsersController ()
@property (retain, nonatomic) EdgeDownloader *offendedUsers;
@end

@implementation OffendedUsersController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProgressCell" bundle:nil] forCellReuseIdentifier:@"ProgressCell"];
    
    if (_offensivePost) {
        _offendedUsers = [[EdgeDownloader alloc] initWithSource:_offensivePost.id edge:@"offended" expand:@[]];
        _offendedUsers.tableView = self.tableView;
        [_offendedUsers getNextPage];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isMemberOfClass:[UserProfileController class]] && [sender isKindOfClass:[OffendedUserCell class]]) {
        UserProfileController * controller = segue.destinationViewController;
        OffendedUserCell * cell = (OffendedUserCell *)sender;
        controller.profileUser = cell.offendedUser;
    }
}

// MARK:- UITableViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [_offendedUsers refreshList];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && ![_offendedUsers isDownloaded]) {
        [_offendedUsers getNextPage];
    }
}

// MARK:- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? _offendedUsers.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        ProgressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
        cell.indicatorIsHidden = tableView.refreshControl.isRefreshing || [_offendedUsers isDownloaded];
        return cell;
    }
    OffendedUserCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OffendedUserCell"];
    cell.offendedUser = (EGFUser *)[_offendedUsers objectAtIndex:indexPath.row];
    return cell;
}
@end
