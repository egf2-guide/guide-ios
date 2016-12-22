//
//  EdgeDownloader.m
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "EdgeDownloader.h"
#import "EGF2.h"

@interface EdgeDownloader ()
@property (nonatomic, retain) NSString *edge;
@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSArray *expand;
@property (nonatomic, assign) BOOL downloading;
@end

@implementation EdgeDownloader

- (BOOL)noAnyData {
    return self.totalCount == -1;
}

- (BOOL)isDownloading {
    return _downloading;
}

- (id)initWithSource:(NSString *)source edge:(NSString *)edge expand:(NSArray *)expand {
    self = [self init];
    self.expand = expand;
    self.source = source;
    self.edge = edge;
    self.pageCount = 25;
    [self addObservers];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK:- Private methods
- (void)addObservers {
    NSObject * object = [[Graph shared] notificationObjectForSource:_source andEdge:_edge];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(edgeDidCreate:) name:EGF2NotificationEdgeCreated object:object];
}

- (void)edgeDidCreate:(NSNotification *)notification {
    NSString * objectId = notification.userInfo[EGF2EdgeObjectIdInfoKey];
    
    if (objectId) {
        [[Graph shared] refreshObjectWithId:objectId expand:_expand completion:^(NSObject * object, NSError * error) {
            if (object) {
                [self insertObject:object atIndex:0];
                [self.delegate didInsertGraphObject:object];
            }
        }];
    }
}

- (void)setObjects:(NSArray *)objects totalCount:(NSInteger)count {
    if (objects && self.tableView) {
        [self.graphObjects removeAllObjects];
        [self.tableView reloadData];
        [self addObjects:objects totalCount:count];
    }
}

- (void)addObjects:(NSArray *)objects totalCount:(NSInteger)count {
    if (objects && self.tableView) {
        NSInteger start = self.graphObjects.count;
        NSInteger end = start + objects.count;
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (NSInteger i = start; i < end; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        self.totalCount = count;
        [self.graphObjects addObjectsFromArray:objects];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)insertObject:(NSObject *)object atIndex:(NSInteger)index {
    if (object && self.tableView) {
        self.totalCount += 1;
        [self.graphObjects insertObject:object atIndex:index];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

// MARK:- Override
- (void)refreshList {
    if (_downloading) {
        return;
    }
    _downloading = true;
    [[Graph shared] refreshObjectsForSource:_source edge:_edge after:nil expand:_expand count:_pageCount completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _downloading = false;
        
        [self setObjects:objects totalCount:count];
        [self.tableView.refreshControl endRefreshing];
    }];
}

- (void)getNextPage {
    if (_downloading) {
        return;
    }
    _downloading = true;
    [[Graph shared] objectsForSource:_source edge:_edge after:[self.last valueForKey:@"id"] expand:_expand count:_pageCount completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _downloading = false;
        
        [self addObjects:objects totalCount:count];
    }];
}
@end
