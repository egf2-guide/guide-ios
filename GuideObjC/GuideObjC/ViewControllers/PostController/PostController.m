//
//  PostController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "PostController.h"
#import "EGFHumanName+Additions.h"
#import "ReversedTableViewHandler.h"
#import "ProgressController.h"
#import "UIColor+Additions.h"
#import "FileImageView.h"
#import "FeedPostCell.h"
#import "CommentCell.h"

@interface PostController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet FileImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *commentPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (retain, nonatomic) ReversedTableViewHandler *comments;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@property (retain, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL isDownloading;
@property (retain, nonatomic) NSArray * expand;
@property (retain, nonatomic) NSString * edge;
@property (retain, nonatomic) EGFUser *user;
@end

@implementation PostController

- (void)viewDidLoad {
    [super viewDidLoad];
    _comments = [[ReversedTableViewHandler alloc] initWithTableView:self.tableView];
    _cellHeights = [NSMutableDictionary dictionary];
    _expand = @[@"creator"];
    _edge = @"comments";
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor whiteColor];
    _refreshControl.tintColor = [UIColor hexColor:0x5E66B1];
    _tableView.refreshControl = _refreshControl;
    
    if (_post) {
        _creatorNameLabel.text = [_post.creatorObject.name fullName];
        _descriptionLabel.text = _post.desc;
        _postImageView.file = _post.imageObject;
        CGFloat headerHeight = [FeedPostCell heightForPost:_post];
        _tableView.tableHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight);
    }
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            _user = (EGFUser *)object;
            [self getNextPage];
        }
    }];
}

- (void)refreshPosts {
    if (!_post.id || _isDownloading) {
        return;
    }
    _isDownloading = true;
    [self.graph refreshObjectsForSource:_post.id edge:_edge after:nil expand:_expand completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _isDownloading = false;
        [self.refreshControl endRefreshing];
        [_comments setObjects:objects totalCount:count];
    }];
    
}

- (void)getNextPage {
    if (!_post.id || _isDownloading) {
        return;
    }
    _isDownloading = true;
    [self.graph objectsForSource:_post.id edge:_edge after:[_comments.last valueForKey:@"id"] expand:_expand completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _isDownloading = false;
        
        [_comments addObjects:objects totalCount:count];
    }];
}

- (void)updateSendButton {
    _commentPlaceholder.hidden = _commentTextView.text.length > 0;
    _sendButton.enabled = _commentTextView.text.length > 0;
}

- (IBAction)sendComment:(id)sender {
    if (_commentTextView.text.length == 0 || !_post.id) {
        return;
    }
    NSDictionary * parameters = @{@"text": _commentTextView.text, @"object_type": @"comment"};
    
    [ProgressController show];
    [self.graph createObjectWithParameters:parameters forSource:_post.id onEdge:_edge completion:^(NSObject * object, NSError * error) {
        [ProgressController hide];
        
        if ([object isKindOfClass:[EGFComment class]]) {
            EGFComment * comment = (EGFComment *)object;
            comment.creatorObject = _user;
            [_comments insertObject:comment atIndex:0];
            _commentTextView.text = @"";
            [self updateSendButton];
            [self textViewDidChange:_commentTextView];
            NSIndexPath * ip = [NSIndexPath indexPathForRow:_comments.count - 1 inSection:1];
            [_tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:true];
        }
    }];
}

- (IBAction)tapOnTableView:(id)sender {
    [_commentTextView resignFirstResponder];
}

// MARK:- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, 1000)];
    CGFloat newHeight = MIN(100, MAX(35.5, size.height));
    
    if (newHeight != _textViewHeight.constant) {
        _textViewHeight.constant = newHeight;
        [self.view layoutIfNeeded];
        [textView setContentOffset:CGPointMake(0, 0) animated:false];
    }
    [self updateSendButton];
}

// MARK:- UITableViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [self refreshPosts];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        EGFComment * comment = (EGFComment *)[_comments objectAtIndex:indexPath.row];
        // Check if we already have the value
        NSNumber * height = _cellHeights[comment.id];
        
        if (height) {
            return [height floatValue];
        }
        CGFloat newHeight = [CommentCell heightForComment:comment];
        _cellHeights[comment.id] = [NSNumber numberWithFloat:newHeight];
        return newHeight;
    }
    return [_comments isDownloaded] || [_comments noAnyData] ? 0 : 50;
}

// MARK:- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NextCommentsCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NextCommentsCell"];
        cell.indicatorIsAnimated = [_comments isDownloaded];
        cell.delegate = self;
        return cell;
    }
    EGFComment * comment = (EGFComment *)[_comments objectAtIndex:indexPath.row];
    CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    cell.creatorNameLabel.text = [comment.creatorObject.name fullName];
    cell.descriptionLabel.text = comment.text;
    return cell;
}

// MARK:- NextCommentsCellDelegate
- (void)showNext {
    if (![_comments isDownloaded] && _isDownloading == false) {
        [self getNextPage];
    }
}
@end
