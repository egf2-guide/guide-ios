//
//  UsersController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UsersController.h"
#import "UIColor+Additions.h"
#import "SearchDownloader.h"
#import "EdgeDownloader.h"
#import "ProgressCell.h"
#import "UserCell.h"
#import "Follows.h"
#import "EGF2.h"

@interface UsersController ()
@property (retain, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (retain, nonatomic) BaseDownloader *activeDownloader;
@property (retain, nonatomic) SearchDownloader *searching;
@property (retain, nonatomic) EdgeDownloader *follows;
@property (retain, nonatomic) UISearchBar * searchBar;
@end

@implementation UsersController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = true;
    _searchBar.tintColor = [UIColor hexColor:0x5E66B1];
    
    EGF2SearchParameters * parameters = [EGF2SearchParameters parametersWithObject:@"user"];
    parameters.fields = @[@"first_name", @"last_name"];
    _searching = [[SearchDownloader alloc] initWithParameters:parameters];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProgressCell" bundle:nil] forCellReuseIdentifier:@"ProgressCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];

    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            EGFUser * user = (EGFUser *)object;
            _follows = [[EdgeDownloader alloc] initWithSource:user.id edge:@"follows" expand:@[]];
            _follows.tableView = self.tableView;
            [_follows getNextPage];
            _activeDownloader = _follows;
        }
    }];
}

- (IBAction)beginSearch:(id)sender {
    _activeDownloader = _searching;
    _activeDownloader.tableView = self.tableView;
    _follows.tableView = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = _searchBar;
    [_searchBar becomeFirstResponder];
}

- (void)endSearch {
    _activeDownloader = _follows;
    _activeDownloader.tableView = self.tableView;
    _searching.tableView = nil;
    _searchBar.text = nil;
    self.navigationItem.rightBarButtonItem = _searchButton;
    self.navigationItem.titleView = nil;
}
                
// MARK:- UserCellDelegate
- (void)didTapFollowButtonWithUser:(EGFUser *)user andCell:(UserCell *)cell {
    if ([[Follows shared] followStateForUser:user] == isFollow) {
        [[Follows shared] unfollowUser:user completion:^{
            cell.user = user;
        }];
    }
    else {
        [[Follows shared] followUser:user completion:^{
            cell.user = user;
        }];
    }
    cell.user = user;
}

// MARK:- UISearchBarDelegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self endSearch];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        [self endSearch];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searching showObjectsWithQuery:searchText];
}
                
// MARK:- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [_activeDownloader refreshList];
    }
}

// MARK:- UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (![_activeDownloader isDownloaded]) {
            [_activeDownloader getNextPage];
        }
    }
}

// MARK:- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _activeDownloader.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        ProgressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
        cell.indicatorIsHidden = tableView.refreshControl.isRefreshing || [_activeDownloader isDownloaded];
        return cell;
    }
    UserCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    cell.user = (EGFUser *)[_activeDownloader objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}
@end
