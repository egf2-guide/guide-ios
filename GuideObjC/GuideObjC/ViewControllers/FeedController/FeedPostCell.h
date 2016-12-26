//
//  FeedPostCell.h
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileImageView.h"
#import "EGF2.h"

@protocol FeedPostCellDelegate <NSObject>
- (NSString *)authorizedUserId;
- (void)deletePost:(EGFPost *)post;
@end

@interface FeedPostCell : UITableViewCell
@property (weak, nonatomic) id <FeedPostCellDelegate> delegate;
@property (weak, nonatomic) EGFPost *post;

+ (CGFloat)heightForPost:(EGFPost *)post;
@end
