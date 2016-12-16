//
//  FeedPostCell.h
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@interface FeedPostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) EGFPost *post;

+ (CGFloat)heightForPost:(EGFPost *)post;

- (void)setPostImage:(UIImage *)image animated:(BOOL)animated;
@end
