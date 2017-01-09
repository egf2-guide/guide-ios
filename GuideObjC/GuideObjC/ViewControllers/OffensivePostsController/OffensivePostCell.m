//
//  OffensivePostCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

#import "OffensivePostCell.h"
#import "EGFHumanName+Additions.h"

@interface OffensivePostCell ()
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet FileImageView *postImageView;
@end

@implementation OffensivePostCell

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

- (void)setPost:(EGFPost *)post {
    _post = post;
    _creatorNameLabel.text = [post.creatorObject.name fullName];
    _descriptionLabel.text = post.desc;
    _postImageView.file = post.imageObject;
}

- (IBAction)deletePost:(id)sender {
    [_delegate deletePost:_post];
}

- (IBAction)confirmAsOffensivePost:(id)sender {
    [_delegate confirmAsOffensive:_post];
}
@end
