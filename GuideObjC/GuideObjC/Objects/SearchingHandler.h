//
//  SearchingHandler.h
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGF2.h"

@protocol SearchingHandlerDelegate <NSObject>
- (void)searchWillBegin;
- (void)searchDidEnd;
@end

@interface SearchingHandler : NSObject <UISearchBarDelegate>
@property (nonatomic, retain) NSMutableArray * graphObjects;
@property (nonatomic, assign) NSInteger totalCount;

- (id)initWithTableViewController:(UITableViewController <SearchingHandlerDelegate>*)tableViewController parameters:(EGF2SearchParameters *)parameters;
- (NSObject *)objectAtIndex:(NSInteger)index;
- (NSInteger)count;
- (BOOL)isDownloaded;
- (void)refreshList;
- (void)getNextPage;
@end
