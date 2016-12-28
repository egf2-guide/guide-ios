//
//  CommentCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "CommentCell.h"
#import "EGFHumanName+Additions.h"

@interface CommentCell ()
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@end

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

- (void)setComment:(EGFComment *)comment {
    _comment = comment;
    _deleteButton.hidden = ![[_delegate authorizedUserId] isEqual:comment.creator];
    _editButton.hidden = ![[_delegate authorizedUserId] isEqual:comment.creator];
    _creatorNameLabel.text = [comment.creatorObject.name fullName];
    _descriptionLabel.text = comment.text;
}

- (IBAction)deleteComment:(id)sender {
    [_delegate deleteComment:_comment];
}

- (IBAction)editComment:(id)sender {
    [_delegate editComment:_comment];
}
@end
