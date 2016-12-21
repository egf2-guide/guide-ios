//
//  SearchingHandler.m
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "SearchingHandler.h"
#import "UIColor+Additions.h"

@interface SearchingHandler ()
@property (nonatomic, weak) UITableViewController <SearchingHandlerDelegate> *tableViewController;
@property (nonatomic, retain) EGF2SearchParameters *parameters;
@property (nonatomic, retain) UIBarButtonItem *searchButton;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, assign) NSInteger searchToken;
@property (nonatomic, retain) NSString *lastQuery;
@end

@implementation SearchingHandler

- (id)init {
    self = [super init];
    
    if (self) {
        _graphObjects = [NSMutableArray array];
    }
    return self;
}

- (id)initWithTableViewController:(UITableViewController <SearchingHandlerDelegate>*)tableViewController parameters:(EGF2SearchParameters *)parameters {
    self = [self init];
    _tableViewController = tableViewController;
    _parameters = parameters;
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = true;
    _searchBar.tintColor = [UIColor hexColor:0x5E66B1];
    _searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(beginSearch)];
    _tableViewController.navigationItem.rightBarButtonItem = _searchButton;
    return self;
}

- (NSObject *)objectAtIndex:(NSInteger)index {
    return _graphObjects[index];
}

- (NSObject *)last {
    return _graphObjects.lastObject;
}

- (NSInteger)count {
    return _graphObjects.count;
}

- (BOOL)isDownloaded {
    return _graphObjects.count == _totalCount;
}

- (void)refreshList {
    if (_lastQuery.length > 0) {
        [self resetSearchWithTotalCount:-1];
        [self showResultsWithQuery:_lastQuery];
    }
}

- (void)getNextPage {
    if (_lastQuery.length > 0 && _graphObjects.count > 0) {
        [self showResultsWithQuery:_lastQuery];
    }
}

- (void)beginSearch {
    [_tableViewController searchWillBegin];
    _tableViewController.navigationItem.rightBarButtonItem = nil;
    _tableViewController.navigationItem.titleView = _searchBar;
    [_searchBar becomeFirstResponder];
    [_tableViewController.tableView reloadData];
    [_tableViewController.tableView.refreshControl endRefreshing];
}

- (void)endSearch {
    _lastQuery = nil;
    _totalCount = 0;
    _searchBar.text = nil;
    _tableViewController.navigationItem.rightBarButtonItem = _searchButton;
    _tableViewController.navigationItem.titleView = nil;
    [_graphObjects removeAllObjects];
    [_tableViewController.tableView reloadData];
    [_tableViewController searchDidEnd];
}

- (void)resetSearchWithTotalCount:(NSInteger)count {
    _searchToken += 1;
    _totalCount = count;
    [_graphObjects removeAllObjects];
    [_tableViewController.tableView reloadData];
}
    
- (void)showResultsWithQuery:(NSString*)query {
    _parameters.query = query;

    NSInteger localSearchToken = _searchToken;
    NSInteger after = _graphObjects.count == 0 ? -1 : _graphObjects.count - 1;
    
    [[Graph shared] searchWithParameters:_parameters after:after count:50 completion:^(NSArray *objects, NSInteger count, NSError * error) {
        // Ignore results of old requests
        if (localSearchToken != _searchToken) {
            return;
        }
        if (objects) {
            _totalCount = count;
            [_graphObjects addObjectsFromArray:objects];
            [_tableViewController.tableView reloadData];
        }
        if (_tableViewController.tableView.refreshControl.isRefreshing) {
            [_tableViewController.tableView.refreshControl endRefreshing];
        }
    }];
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
    [self resetSearchWithTotalCount:searchText.length == 0 ? 0 : -1];
    
    if (searchText.length > 0) {
        SEL selector = @selector(showResultsWithQuery:);
        
        if (_lastQuery) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:_lastQuery];
        }
        [self performSelector:selector withObject:searchText afterDelay:0.5];
        _lastQuery = searchText;
    }
}
@end
