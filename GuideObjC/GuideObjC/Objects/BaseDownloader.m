//
//  BaseDownloader.m
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseDownloader.h"

@implementation BaseDownloader

- (id)init {
    self = [super init];
    
    if (self) {
        _graphObjects = [NSMutableArray array];
        _totalCount = -1;
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    
    if (tableView) {
        [tableView reloadData];
        [tableView.refreshControl endRefreshing];
    }
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
    // Override this
}

- (void)getNextPage {
    // Override this
}
@end
