//
//  PostController.h
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseViewController.h"
#import "NextCommentsCell.h"
#import "EdgeDownloader.h"
#import "EGF2.h"

@interface PostController : BaseViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, NextCommentsCellDelegate, EdgeDownloaderDelegate>
@property (retain, nonatomic) EGFPost *post;
@end
