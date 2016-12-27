//
//  PostCell.h
//  GuideObjC
//
//  Created by LuzanovRoman on 27.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileImageView.h"
#import "EGF2.h"

@protocol PostCellDelegate <NSObject>
- (NSString *)authorizedUserId;
- (void)deletePost:(EGFPost *)post;
@end

@interface PostCell : UITableViewCell
@property (weak, nonatomic) id <PostCellDelegate> delegate;
@property (weak, nonatomic) EGFPost *post;

+ (CGFloat)heightForPost:(EGFPost *)post;
@end
