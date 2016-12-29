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
    if (objects) {
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

- (void)replaceObject:(NSObject *)object {
    if (object) {
        NSInteger index = [self indexOfObject:object];
        
        if (index == NSNotFound) {
            return;
        }
        [self.graphObjects replaceObjectAtIndex:index withObject:object];
        
        if (self.tableView) {
            if ([self.delegate respondsToSelector:@selector(willUpdateGraphObject:)]) {
                [self.delegate willUpdateGraphObject:object];
            }
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
            if ([self.delegate respondsToSelector:@selector(didUpdateGraphObject:)]) {
                [self.delegate didUpdateGraphObject:object];
            }
        }
    }
}

- (void)insertObject:(NSObject *)object atIndex:(NSInteger)index {
    if (object) {
        // Check if object is already in the list
        if ([self indexOfObject:object] != NSNotFound) {
            return;
        }
        NSInteger insertIndex = self.graphObjects.count - index;
        self.totalCount += 1;
        [self.graphObjects insertObject:object atIndex:insertIndex];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)deleteObject:(NSObject *)object {
    NSInteger index = [self.graphObjects indexOfObject:object];
    
    if (index == NSNotFound) {
        return;
    }
    self.totalCount -= 1;
    [self.graphObjects removeObjectAtIndex:index];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}
@end
