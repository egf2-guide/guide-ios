//
//  FeedController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "FeedController.h"
#import "FeedProgressCell.h"
#import "EGFHumanName+Additions.h"
#import "SimpleFileManager.h"
#import "EdgeDownloader.h"
#import "PostController.h"
#import "FeedPostCell.h"
#import "EGF2.h"

@interface FeedController ()
@property (retain, nonatomic) EdgeDownloader *posts;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@end

@implementation FeedController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cellHeights = [NSMutableDictionary dictionary];
    
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            _posts = [[EdgeDownloader alloc] initWithSource:[object valueForKey:@"id"] edge:@"posts" expand:@[@"creator",@"image"]];
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
    EGFPost * post = (EGFPost *)[_posts objectAtIndex:indexPath.row];
    FeedPostCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    cell.creatorNameLabel.text = [post.creatorObject.name fullName];
    cell.descriptionLabel.text = post.desc;
    cell.postImageView.file = post.imageObject;
    return cell;
}
@end
