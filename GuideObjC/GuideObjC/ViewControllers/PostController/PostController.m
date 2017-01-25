//
//  PostController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "PostController.h"
#import "UIViewController+Additions.h"
#import "EGFHumanName+Additions.h"
#import "ReversedEdgeDownloader.h"
#import "OffensivePostButton.h"
#import "ProgressController.h"
#import "PostEditController.h"
#import "UIColor+Additions.h"
#import "EdgeDownloader.h"
#import "OffensivePosts.h"
#import "FileImageView.h"
#import "CommentCell.h"
#import "PostCell.h"

@interface PostController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet FileImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editButtonWidth;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonWidth;
@property (weak, nonatomic) IBOutlet OffensivePostButton *offensiveButton;
@property (weak, nonatomic) IBOutlet UILabel *commentPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (retain, nonatomic) ReversedEdgeDownloader *comments;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@property (retain, nonatomic) UIRefreshControl *refreshControl;
@property (retain, nonatomic) EGFComment *editedComment;
@property (retain, nonatomic) EGFUser *currentUser;
@property (retain, nonatomic) NSString *edge;
@end

@implementation PostController

- (void)viewDidLoad {
    [super viewDidLoad];
    _edge = @"comments";
    _cellHeights = [NSMutableDictionary dictionary];

    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor whiteColor];
    _refreshControl.tintColor = [UIColor hexColor:0x5E66B1];
    _tableView.refreshControl = _refreshControl;
    
    if (_post) {
        [self updateHeader];
        
        _comments = [[ReversedEdgeDownloader alloc] initWithSource:_post.id edge:_edge expand:@[@"creator"]];
        _comments.delegate = self;
        _comments.pageCount = 5;
        _comments.tableView = self.tableView;
        [_comments getNextPage];
        _offensiveButton.post = _post;
        
        [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
            if ([object isKindOfClass:[EGFUser class]]) {
                _currentUser = (EGFUser *)object;
                BOOL isUserPost = [_post.creator isEqual:_currentUser.id];
                _editButton.hidden = !isUserPost;
                _editButtonWidth.constant = isUserPost ? 30 : 0;
                _offensiveButton.hidden = isUserPost;
                // TODO use isUserPost when support is ready
                _deleteButton.hidden = true;
                _deleteButtonWidth.constant = 0;
            }
        }];
        [[Graph shared] addObserver:self selector:@selector(postUpdated:) name:EGF2NotificationObjectUpdated forSource:_post.id];
    }
}

- (void)dealloc {
    [[Graph shared] removeObserver:self];
}

- (void)postUpdated:(NSNotification *)notification {
    NSString * postId = notification.userInfo[EGF2ObjectIdInfoKey];
    
    [self.graph objectWithId:postId expand:@[@"creator",@"image"] completion:^(NSObject * object, NSError * error) {
        if (object) {
            _post = (EGFPost *)object;
            [self updateHeader];
        }
    }];
}

- (void)updateHeader {
    _creatorNameLabel.text = [_post.creatorObject.name fullName];
    _descriptionLabel.text = _post.desc;
    _postImageView.file = _post.imageObject;
    [_tableView beginUpdates];
    _tableView.tableHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, [PostCell heightForPost:_post]);
    [_tableView endUpdates];
}

- (void)updateSendButton {
    _commentPlaceholder.hidden = _commentTextView.text.length > 0;
    _sendButton.enabled = _commentTextView.text.length > 1;
}

- (IBAction)markPostAsOffensive:(id)sender {
    if (_post.id) {
        if ([[OffensivePosts shared] offensiveStateForPost:_post] == osOffensive) {
            [self showAlertWithTitle:@"Offensive Post" message:@"You've marked the post as offensive"];
            return;
        }
        [self showConfirmWithTitle:@"Warning" message:@"Mark Post as offensive?" action:^{
            [[OffensivePosts shared] markAsOffensive:_post completion:^{
                [_offensiveButton checkOffensiveState];
            }];
            [_offensiveButton checkOffensiveState];
        }];
    }
}

- (IBAction)deletePost:(id)sender {
    if (_currentUser.id && _post.id) {
        [self showConfirmWithTitle:@"Warning" message:@"Really delete?" action:^{
            [ProgressController show];
            [self.graph deleteObjectWithId:_post.id forSource:_currentUser.id fromEdge:@"posts" completion:^(id object, NSError * error) {
                [ProgressController hide];
                
                if (!error) {
                    [self.navigationController popViewControllerAnimated:true];
                }
            }];
        }];
    }
}

- (IBAction)sendComment:(id)sender {
    if (_editedComment) {
        [ProgressController show];
        [self.graph updateObjectWithId:_editedComment.id parameters:@{@"text":_commentTextView.text} completion:^(NSObject * object, NSError * error) {
            [ProgressController hide];
            
            if (!error) {
                [self endEditing];
                [self updateSendButton];
                [self textViewDidChange:_commentTextView];
            }
        }];
        return;
    }
    if (_commentTextView.text.length == 0 || !_post.id) {
        return;
    }
    NSDictionary * parameters = @{@"text": _commentTextView.text, @"object_type": @"comment"};
    
    [ProgressController show];
    [self.graph createObjectWithParameters:parameters forSource:_post.id onEdge:@"comments" completion:^(NSObject * object, NSError * error) {
        [ProgressController hide];
        
        if ([object isKindOfClass:[EGFComment class]]) {
            EGFComment * comment = (EGFComment *)object;
            comment.creatorObject = _currentUser;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isMemberOfClass:[PostEditController class]]) {
        ((PostEditController *)segue.destinationViewController).post = _post;
        [_commentTextView resignFirstResponder];
    }
}

- (void)startEditingWithComment:(EGFComment *)comment {
    _editedComment = comment;
    [_sendButton setTitle:@"Update" forState:UIControlStateNormal];
    _commentTextView.text = comment.text;
    [_commentTextView becomeFirstResponder];
    [self textViewDidChange:_commentTextView];
    [self updateSendButton];
    
    NSInteger index = [_comments.graphObjects indexOfObject:_editedComment];
    
    if (index != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:1];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
        });
    }
}

- (void)endEditing {
    _editedComment = nil;
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    _commentTextView.text = @"";
    [self textViewDidChange:_commentTextView];
    [self updateSendButton];
}

// MARK:- BaseDownloaderDelegate
- (void)willUpdateGraphObject:(NSObject *)graphObject {
    NSString * id = [graphObject valueForKey:@"id"];
    
    if (id) {
        [_cellHeights removeObjectForKey:id];
    }
}

- (void)didUpdateGraphObject:(NSObject *)graphObject {
    NSInteger index = [_comments indexOfObject:graphObject];

    if (index != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:1];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
    }
}

// MARK:- CommentCellDelegate
- (NSString *)authorizedUserId {
    return _currentUser.id;
}

- (void)deleteComment:(EGFComment *)comment {
    if (comment.id && _post.id) {
        [self showConfirmWithTitle:@"Warning" message:@"Really delete?" action:^{
            [ProgressController show];
            [self.graph deleteObjectWithId:comment.id forSource:_post.id fromEdge:_edge completion:^(id object, NSError * error) {
                [ProgressController hide];
            }];
        }];
    }
}

- (void)editComment:(EGFComment *)comment {
    [self startEditingWithComment:comment];
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

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (_editedComment) {
        [self endEditing];
    }
}

// MARK:- UITableViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [_comments refreshList];
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
    CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    cell.delegate = self;
    cell.comment = (EGFComment *)[_comments objectAtIndex:indexPath.row];
    return cell;
}

// MARK:- NextCommentsCellDelegate
- (void)showNext {
    if (![_comments isDownloaded]) {
        [_comments getNextPage];
    }
}
@end
