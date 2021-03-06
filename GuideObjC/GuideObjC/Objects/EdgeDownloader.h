//
//  EdgeDownloader.h
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseDownloader.h"


@interface EdgeDownloader : BaseDownloader
@property (nonatomic, assign) NSInteger pageCount;

- (id)initWithSource:(NSString *)source edge:(NSString *)edge;
- (id)initWithSource:(NSString *)source edge:(NSString *)edge expand:(NSArray *)expand;
- (void)insertObject:(NSObject *)object atIndex:(NSInteger)index;
- (BOOL)noAnyData;
- (void)updateSubscriptionsForObjects:(NSArray *)objects;
@end
