//
//  TableViewHandler.m
//  GuideObjC
//
//  Created by LuzanovRoman on 15.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "TableViewHandler.h"
#import <UIKit/UIKit.h>

@interface TableViewHandler ()
@property (nonatomic, retain) NSMutableArray * graphObjects;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation TableViewHandler

- (id)init {
    self = [super init];
    
    if (self) {
        _graphObjects = [NSMutableArray array];
        _totalCount = -1;
    }
    return self;
}

- (id)initWithTableView:(UITableView *)tableView {
    self = [self init];
    self.tableView = tableView;
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

- (void)setObjects:(NSArray *)objects totalCount:(NSInteger)count {
    if (objects) {
        [_graphObjects removeAllObjects];
        [_tableView reloadData];
        [self addObjects:objects totalCount:count];
    }
}

- (void)addObjects:(NSArray *)objects totalCount:(NSInteger)count {
    if (objects) {
        NSInteger start = _graphObjects.count;
        NSInteger end = start + objects.count;
        NSMutableArray *indexPaths = [NSMutableArray array];

        for (NSInteger i = start; i < end; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        _totalCount = count;
        [_graphObjects addObjectsFromArray:objects];

        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
    }
}

- (void)insertObject:(NSObject *)object atIndex:(NSInteger)index {
    if (object) {
        _totalCount += 1;
        [_graphObjects insertObject:object atIndex:index];
        
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
    }
}
@end
