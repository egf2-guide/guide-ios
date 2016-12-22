//
//  EdgeDownloader.h
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseDownloader.h"

@interface EdgeDownloader : BaseDownloader
- (id)initWithSource:(NSString *)source edge:(NSString *)edge expand:(NSArray *)expand;
- (BOOL)noAnyData;
@end
