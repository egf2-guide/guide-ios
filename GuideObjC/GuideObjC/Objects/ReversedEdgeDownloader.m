//
//  ReversedEdgeDownloader.m
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "ReversedEdgeDownloader.h"

@implementation ReversedEdgeDownloader

- (NSObject *)last {
    return self.graphObjects.firstObject;
}

- (void)addObjects:(NSArray *)objects totalCount:(NSInteger)count {
    if (objects && self.tableView) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (NSInteger i = 0; i < objects.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }
        self.totalCount = count;
        
        for (NSObject * object in objects) {
            [self.graphObjects insertObject:object atIndex:0];
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)insertObject:(NSObject *)object atIndex:(NSInteger)index {
    if (object && self.tableView) {
        NSInteger insertIndex = self.graphObjects.count - index;
        self.totalCount += 1;
        [self.graphObjects insertObject:object atIndex:insertIndex];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}
@end
