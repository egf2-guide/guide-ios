//
//  BaseDownloader.h
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseDownloaderDelegate <NSObject>
@optional
- (void)willUpdateGraphObject:(NSObject *)graphObject;
- (void)didUpdateGraphObject:(NSObject *)graphObject;
@end

@interface BaseDownloader : NSObject
@property (nonatomic, weak) id <BaseDownloaderDelegate> delegate;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * graphObjects;
@property (nonatomic, assign) NSInteger totalCount;

// For childs
- (NSInteger)indexOfObjectWithId:(NSString *)id;
- (NSInteger)indexOfObject:(NSObject *)object;
- (void)replaceObject:(NSObject *)object;
- (NSArray *)expandValues;

- (NSObject *)objectAtIndex:(NSInteger)index;
- (NSObject *)last;
- (NSInteger)count;
- (BOOL)isDownloaded;
- (void)refreshList;
- (void)getNextPage;
@end
