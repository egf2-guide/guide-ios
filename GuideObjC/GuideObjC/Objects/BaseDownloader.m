//
//  BaseDownloader.m
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseDownloader.h"
#import "EGF2.h"

@implementation BaseDownloader

- (id)init {
    self = [super init];
    
    if (self) {
        _graphObjects = [NSMutableArray array];
        _totalCount = -1;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (NSInteger)indexOfObjectWithId:(NSString *)id {
    for (NSInteger i = 0; i< _graphObjects.count; i++) {
        if ([[[_graphObjects objectAtIndex:i] valueForKey:@"id"] isEqual:id]) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSInteger)indexOfObject:(NSObject *)object {
    NSString *id = [object valueForKey:@"id"];
    
    if (id) {
        return [self indexOfObjectWithId:id];
    }
    return NSNotFound;
}

- (void)replaceObject:(NSObject *)object {
    NSInteger index = [self indexOfObject:object];
    
    if (index == NSNotFound) {
        return;
    }
    [_graphObjects replaceObjectAtIndex:index withObject:object];
    
    if (_tableView) {
        if ([_delegate respondsToSelector:@selector(willUpdateGraphObject:)]) {
            [_delegate willUpdateGraphObject:object];
        }
        [_tableView beginUpdates];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
        
        if ([_delegate respondsToSelector:@selector(didUpdateGraphObject:)]) {
            [_delegate didUpdateGraphObject:object];
        }
    }
}

// MARK:- Override
- (NSArray *)expandValues {
    return @[];
}

- (void)refreshList {
    // Override this
}

- (void)getNextPage {
    // Override this
}
@end
