//
//  SearchDownloader.m
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "SearchDownloader.h"

@interface SearchDownloader ()
@property (nonatomic, retain) EGF2SearchParameters *parameters;
@property (nonatomic, assign) NSInteger searchToken;
@property (nonatomic, retain) NSString *lastQuery;
@property (nonatomic, retain) NSString *lastToken;
@end

@implementation SearchDownloader

- (void)setTableView:(UITableView *)tableView {
    [super setTableView:tableView];
    
    if (tableView == nil) {
        [self resetSearchWithTotalCount:0];
        _lastQuery = nil;
    }
}

- (id)initWithParameters:(EGF2SearchParameters *)parameters {
    self = [self init];
    _parameters = parameters;
    self.totalCount = 0;
    return self;
}

- (NSArray *)expandValues {
    return _parameters.expand;
}

- (void)refreshList {
    if (_lastQuery.length > 0) {
        [self resetSearchWithTotalCount:-1];
        [self showResultsWithQuery:_lastQuery];
    }
}

- (void)getNextPage {
    if (_lastQuery.length > 0 && self.graphObjects.count > 0) {
        [self showResultsWithQuery:_lastQuery];
    }
}

- (void)resetSearchWithTotalCount:(NSInteger)count {
    _searchToken += 1;
    _lastToken = nil;
    self.totalCount = count;
    [self.graphObjects removeAllObjects];
    [self.tableView reloadData];
}

- (void)showResultsWithQuery:(NSString*)query {
    if (self.tableView == nil) {
        return;
    }
    _parameters.query = query;
    
    NSInteger localSearchToken = _searchToken;
    
    [[Graph shared] searchWithParameters:_parameters count:50 after:_lastToken completion:^(NSArray *objects, NSInteger count, NSString *last, NSError * error) {
        // Ignore results of old requests
        if (localSearchToken != _searchToken) {
            return;
        }
        if (objects) {
            _lastToken = last;
            self.totalCount = count;
            [self.graphObjects addObjectsFromArray:objects];
            [self.tableView reloadData];
        }
        if (self.tableView.refreshControl.isRefreshing) {
            [self.tableView.refreshControl endRefreshing];
        }
    }];
}

- (void)showObjectsWithQuery:(NSString*)query {
    [self resetSearchWithTotalCount:query.length == 0 ? 0 : -1];
    
    if (query.length > 0) {
        SEL selector = @selector(showResultsWithQuery:);
        
        if (_lastQuery) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:_lastQuery];
        }
        [self performSelector:selector withObject:query afterDelay:0.5];
        _lastQuery = query;
    }
}
@end
