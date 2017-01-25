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
@property (nonatomic, retain) NSMutableArray *subscribedObjectIds;
@property (nonatomic, assign) BOOL downloading;
@end

@implementation EdgeDownloader

- (BOOL)noAnyData {
    return self.totalCount == -1;
}

- (BOOL)isDownloading {
    return _downloading;
}

- (id)initWithSource:(NSString *)source edge:(NSString *)edge {
    return [self initWithSource:source edge:edge expand:@[]];
}

- (id)initWithSource:(NSString *)source edge:(NSString *)edge expand:(NSArray *)expand {
    self = [self init];
    
    if (self) {
        self.expand = expand;
        self.source = source;
        self.edge = edge;
        self.pageCount = 25;
        self.subscribedObjectIds = [NSMutableArray array];
        [[Graph shared] addObserver:self selector:@selector(edgeCreated:) name:EGF2NotificationEdgeCreated forSource:source andEdge:edge];
        [[Graph shared] addObserver:self selector:@selector(edgeRemoved:) name:EGF2NotificationEdgeRemoved forSource:source andEdge:edge];
    }
    return self;
}

- (void)dealloc {
    [[Graph shared] removeObserver:self];
}

// MARK:- Private methods
- (void)edgeCreated:(NSNotification *)notification {
    NSString * objectId = notification.userInfo[EGF2EdgeObjectIdInfoKey];
    
    if (objectId) {
        __weak EdgeDownloader *weakSelf = self;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (weakSelf) {
                [[Graph shared] addObserver:weakSelf selector:@selector(objectUpdated:) name:EGF2NotificationObjectUpdated forSource:objectId];
                [[Graph shared] objectWithId:objectId expand:weakSelf.expandValues completion:^(NSObject * object, NSError * error) {
                    if (object) {
                        [weakSelf insertObject:object atIndex:0];
                    }
                }];
            }
        });
    }
}

- (void)edgeRemoved:(NSNotification *)notification {
    NSString * objectId = notification.userInfo[EGF2EdgeObjectIdInfoKey];
    
    if (objectId) {
        NSInteger index = [self indexOfObjectWithId:objectId];
        [self deleteObjectAtIndex:index];
        [[Graph shared] removeObserver:self name:EGF2NotificationObjectUpdated fromSource:objectId];
        [_subscribedObjectIds removeObject:objectId];
    }
}

- (void)objectUpdated:(NSNotification *)notification {
    NSString * objectId = notification.userInfo[EGF2ObjectIdInfoKey];
    
    if (objectId) {
        [[Graph shared] objectWithId:objectId expand:[self expandValues] completion:^(NSObject * object, NSError * error) {
            if (object) {
                [self replaceObject:object];
            }
        }];
    }
}

- (void)updateSubscriptionsForObjects:(NSArray *)objects  {
    NSMutableArray *newSubscribedObjectIds = [NSMutableArray array];
    
    for (NSObject *object in objects) {
        NSString *objectId =  [object valueForKey:@"id"];
        
        if (![_subscribedObjectIds containsObject:objectId]) {
            [newSubscribedObjectIds addObject:objectId];
        }
    }
    if (newSubscribedObjectIds.count > 0) {
        [[Graph shared] addObserver:self selector:@selector(objectUpdated:) name:EGF2NotificationObjectUpdated forSources:newSubscribedObjectIds];
    }
}

- (void)setObjects:(NSArray *)objects totalCount:(NSInteger)count {
    if (objects) {
        [self.graphObjects removeAllObjects];
        [self.tableView reloadData];
        [self addObjects:objects totalCount:count];
    }
}

- (void)addObjects:(NSArray *)objects totalCount:(NSInteger)count {
    if (objects) {
        BOOL addAnimated = self.graphObjects.count > 0;
        NSInteger start = self.graphObjects.count;
        NSInteger end = start + objects.count;
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (NSInteger i = start; i < end; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        self.totalCount = count;
        [self.graphObjects addObjectsFromArray:objects];
        
        if (addAnimated) {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
        else {
            [self.tableView reloadData];
        }
        [self updateSubscriptionsForObjects:objects];
    }
}

- (void)insertObject:(NSObject *)object atIndex:(NSInteger)index {
    if (object) {
        // Check if object is already in the list
        if ([self indexOfObject:object] != NSNotFound) {
            return;
        }
        self.totalCount += 1;
        [self.graphObjects insertObject:object atIndex:index];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)deleteObjectAtIndex:(NSInteger)index {
    if (self.graphObjects.count == 0 || self.graphObjects.count <= index) {
        return;
    }
    self.totalCount -= 1;
    [self.graphObjects removeObjectAtIndex:index];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)deleteObject:(NSObject *)object {
    NSInteger index = [self.graphObjects indexOfObject:object];
    
    if (index != NSNotFound) {
        [self deleteObjectAtIndex:index];
    }
}

// MARK:- Override
- (NSArray *)expandValues {
    return _expand;
}

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
