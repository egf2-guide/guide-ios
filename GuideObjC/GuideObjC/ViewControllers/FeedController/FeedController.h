//
//  FeedController.h
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BaseDownloader.h"
#import "PostCell.h"

@interface FeedController : BaseTableViewController <PostCellDelegate, UISearchBarDelegate, BaseDownloaderDelegate>

@end
