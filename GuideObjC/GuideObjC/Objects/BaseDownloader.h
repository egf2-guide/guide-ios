//
//  BaseDownloader.h
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseDownloader : NSObject
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * graphObjects;
@property (nonatomic, assign) NSInteger totalCount;

- (NSObject *)objectAtIndex:(NSInteger)index;
- (NSObject *)last;
- (NSInteger)count;
- (BOOL)isDownloaded;
- (void)refreshList;
- (void)getNextPage;
@end
