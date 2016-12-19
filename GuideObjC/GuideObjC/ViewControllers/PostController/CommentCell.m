//
//  CommentCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

+ (CGFloat)heightForComment:(EGFComment *)comment {
    CGFloat height = 47; // height of cell without text
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 32;
    
    if (comment.text) {
        CGSize size = CGSizeMake(width, FLT_MAX);
        CGRect frame = [comment.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
        height += frame.size.height + 8;
    }
    return height;
}
@end
