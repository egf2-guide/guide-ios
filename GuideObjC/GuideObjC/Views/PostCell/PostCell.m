//
//  PostCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 27.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "PostCell.h"
#import "EGFHumanName+Additions.h"

@interface PostCell ()
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet FileImageView *postImageView;
@end

@implementation PostCell

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
    _deleteButton.hidden = ![[_delegate authorizedUserId] isEqual:post.creator];
    _creatorNameLabel.text = [post.creatorObject.name fullName];
    _descriptionLabel.text = post.desc;
    _postImageView.file = post.imageObject;
}

- (IBAction)deletePost:(id)sender {
    [_delegate deletePost:_post];
}
@end
