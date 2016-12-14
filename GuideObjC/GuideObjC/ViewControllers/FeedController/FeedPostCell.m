//
//  FeedPostCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "FeedPostCell.h"

@interface FeedPostCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageHeight;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@end

@implementation FeedPostCell

- (void)setPostImage:(UIImage *)postImage {
    _postImage = postImage;
    
    if (postImage) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 32;
        CGFloat imageRatio = postImage.size.width / postImage.size.height;
        CGFloat imageWidth = MIN(width, postImage.size.width / [UIScreen mainScreen].scale);
        _postImageHeight.constant = imageWidth / imageRatio;
    }
    else {
        _postImageHeight.constant = 0;
    }
    _postImageView.image = postImage;
}
@end
