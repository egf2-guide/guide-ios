//
//  FeedController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "FeedController.h"
#import "UIViewController+Additions.h"
#import "EGFHumanName+Additions.h"
#import "ProgressController.h"
#import "SimpleFileManager.h"
#import "FeedProgressCell.h"
#import "EdgeDownloader.h"
#import "PostController.h"
#import "EGF2.h"

@interface FeedController ()
@property (retain, nonatomic) EdgeDownloader *posts;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@property (retain, nonatomic) NSString *currentUserId;
@property (retain, nonatomic) NSString *edge;
@end

@implementation FeedController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cellHeights = [NSMutableDictionary dictionary];
    _edge = @"posts";
    
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            _currentUserId = [object valueForKey:@"id"];
            _posts = [[EdgeDownloader alloc] initWithSource:_currentUserId edge:_edge expand:@[@"creator",@"image"]];
            _posts.tableView = self.tableView;
            [_posts getNextPage];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isMemberOfClass:[PostController class]] && [sender isKindOfClass:[UITableViewCell class]]) {
        PostController * postController = segue.destinationViewController;
        NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
        postController.post = (EGFPost *)[_posts objectAtIndex:indexPath.row];
    }
}

// MARK:- FeedPostCellDelegate
- (NSString *)authorizedUserId {
    return _currentUserId;
}

- (void)deletePost:(EGFPost *)post {
    if (_currentUserId && post.id) {
        [self showConfirmWithTitle:@"Warning" message:@"Really delete?" action:^{
            [ProgressController show];
            [self.graph deleteObjectWithId:post.id forSource:_currentUserId fromEdge:@"posts" completion:^(id object, NSError * error) {
                [ProgressController hide];
            }];
        }];
    }
}

// MARK:- UITableViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [_posts refreshList];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EGFPost * post = (EGFPost *)[_posts objectAtIndex:indexPath.row];
        // Check if we already have the value
        NSNumber * height = _cellHeights[post.id];
        
        if (height) {
            return [height floatValue];
        }
        CGFloat newHeight = [FeedPostCell heightForPost:post];
        _cellHeights[post.id] = [NSNumber numberWithFloat:newHeight];
        return newHeight;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && ![_posts isDownloaded]) {
        [_posts getNextPage];
    }
}

// MARK:- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? _posts.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        FeedProgressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
        cell.indicatorIsHidden = [_posts isDownloaded];
        return cell;
    }
    FeedPostCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    cell.delegate = self;
    cell.post = (EGFPost *)[_posts objectAtIndex:indexPath.row];
    return cell;
}
@end
