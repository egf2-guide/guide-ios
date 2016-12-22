//
//  UsersController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UsersController.h"
#import "TableViewHandler.h"
#import "ProgressCell.h"
#import "UserCell.h"
#import "EGF2.h"

@interface UsersController ()
@property (retain, nonatomic) TableViewHandler *follows;
@property (retain, nonatomic) SearchingHandler *searchingHandler;
@property (retain, nonatomic) NSString *currentUserId;
@property (assign, nonatomic) BOOL isSearching;
@property (assign, nonatomic) BOOL isDownloading;
@property (retain, nonatomic) NSArray * expand;
@property (retain, nonatomic) NSString * edge;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@end

@implementation UsersController

- (void)awakeFromNib {
    [super awakeFromNib];
    // TODO remove
//    self.tabBarController.selectedIndex = 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EGF2SearchParameters * parameters = [EGF2SearchParameters parametersWithObject:@"user"];
    parameters.fields = @[@"first_name", @"last_name"];
    
    _follows = [[TableViewHandler alloc] initWithTableView:self.tableView];
    _searchingHandler = [[SearchingHandler alloc] initWithTableViewController:self parameters:parameters];
    _edge = @"follows";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProgressCell" bundle:nil] forCellReuseIdentifier:@"ProgressCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];

    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            _currentUserId = ((EGFUser *)object).id;
            [self getNextPage];
        }
    }];
}

- (void)refreshList {
    if (_isSearching) {
        [_searchingHandler refreshList];
    }
    else {
        if (!_currentUserId || _isDownloading) {
            return;
        }
        _isDownloading = true;
        [self.graph refreshObjectsForSource:_currentUserId edge:_edge completion:^(NSArray * objects, NSInteger count, NSError * error) {
            _isDownloading = false;
            
            if (!_isSearching) {
                [_follows setObjects:objects totalCount:count];
                [self.refreshControl endRefreshing];
            }
        }];
    }
}

- (void)getNextPage {
    if (!_currentUserId || _isDownloading) {
        return;
    }
    _isDownloading = true;
    [self.graph objectsForSource:_currentUserId edge:_edge after:[_follows.last valueForKey:@"id"] completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _isDownloading = false;
        
        if (!_isSearching) {
            [_follows addObjects:objects totalCount:count];
        }
    }];
}


// MARK:- UserCellDelegate
- (void)didTapFollowButtonWithUser:(EGFUser *)user {
    // TODO
}

// MARK:- SearchingHandlerDelegate
- (void)searchWillBegin {
    _isSearching = true;
}

- (void)searchDidEnd {
    _isSearching = false;
    [self.tableView reloadData];
}

// MARK:- UITableViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [self refreshList];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if (_isSearching) {
            if (![_searchingHandler isDownloaded]) {
                [_searchingHandler getNextPage];
            }
        }
        else {
            if (![_follows isDownloaded] && !_isDownloading) {
                [self getNextPage];
            }
        }
    }
}

// MARK:- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _isSearching ? _searchingHandler.count : _follows.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        ProgressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
        cell.indicatorIsHidden = tableView.refreshControl.isRefreshing || (_isSearching ? [_searchingHandler isDownloaded] : [_follows isDownloaded]);
        return cell;
    }
    UserCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    cell.user = _isSearching ? (EGFUser *)[_searchingHandler objectAtIndex:indexPath.row] :(EGFUser *) [_follows objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}
@end
