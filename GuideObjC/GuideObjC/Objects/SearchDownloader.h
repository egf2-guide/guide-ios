//
//  SearchDownloader.h
//  GuideObjC
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseDownloader.h"
#import "EGF2.h"

@interface SearchDownloader : BaseDownloader
- (id)initWithParameters:(EGF2SearchParameters *)parameters;
- (void)showObjectsWithQuery:(NSString*)query;
@end
