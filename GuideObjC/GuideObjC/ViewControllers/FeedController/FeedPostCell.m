//
//  FeedPostCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "FeedPostCell.h"
#import "EGF2.h"

@implementation FeedPostCell

+ (CGFloat)heightForPost:(EGFPost *)post {
    CGFloat height = 46; // height of cell without image and description
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 32;
    
    if (post.desc) {
        CGSize size = CGSizeMake(width, FLT_MAX);
        CGRect frame = [post.desc boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
        height += frame.size.height + 8;
    }
    if (post.imageObject.dimensions) {
        EGFDimension * dimension = post.imageObject.dimensions;
        CGFloat w = dimension.width;
        CGFloat h = dimension.height;
        CGFloat imageRatio = w / h;
        CGFloat imageWidth = MIN(width, w / [UIScreen mainScreen].scale);
        CGFloat imageHeight = imageWidth / imageRatio;
        height += imageHeight + 8;
    }
    return height;
}
@end
