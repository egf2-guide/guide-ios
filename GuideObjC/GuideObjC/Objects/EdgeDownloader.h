//
//  EdgeDownloader.h
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseDownloader.h"

@protocol EdgeDownloaderDelegate <NSObject>
- (void)didInsertGraphObject:(NSObject *)graphObject;
@end

@interface EdgeDownloader : BaseDownloader
@property (nonatomic, weak) id<EdgeDownloaderDelegate> delegate;
@property (nonatomic, assign) NSInteger pageCount;

- (id)initWithSource:(NSString *)source edge:(NSString *)edge expand:(NSArray *)expand;
- (BOOL)noAnyData;
@end
