//
//  TableViewHandler.h
//  GuideObjC
//
//  Created by LuzanovRoman on 15.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewHandler : NSObject
- (id)initWithTableView:(UITableView *)tableView;
- (NSObject *)objectAtIndex:(NSInteger)index;
- (NSObject *)last;
- (NSInteger)count;
- (BOOL)isDownloaded;
- (void)setObjects:(NSArray *)objects totalCount:(NSInteger)count;
- (void)addObjects:(NSArray *)objects totalCount:(NSInteger)count;
- (void)insertObject:(NSObject *)object atIndex:(NSInteger)index;
@end
