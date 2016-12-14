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
#import "FeedPostCell.h"
#import "EGF2.h"

@interface FeedController ()
@property (retain, nonatomic) NSMutableArray <EGFPost *> *posts;
@property (retain, nonatomic) NSString *currentUserId;
@property (assign, nonatomic) NSInteger postCount;
@property (assign, nonatomic) BOOL isDownloading;
@property (retain, nonatomic) NSArray * expand;
@end

@implementation FeedController

- (void)viewDidLoad {
    [super viewDidLoad];
    _posts = [NSMutableArray array];
    _expand = @[@"creator",@"image"];
    _postCount = -1;
    
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            _currentUserId = ((EGFUser *)object).id;
            [self getNextPage];
        }
    }];
}

- (void)refreshPosts {
    if (!_currentUserId || _isDownloading) {
        return;
    }
    _isDownloading = true;
    [self.graph refreshObjectsForSource:_currentUserId edge:@"posts" after:nil expand:_expand completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _isDownloading = false;
        
        if (objects) {
            [_posts removeAllObjects];
            [self addNextPosts:objects count:count];
        }
        [self.refreshControl endRefreshing];
    }];
    
}

- (void)getNextPage {
    if (!_currentUserId || _isDownloading) {
        return;
    }
    _isDownloading = true;
    [self.graph objectsForSource:_currentUserId edge:@"posts" after:_posts.lastObject.id expand:_expand completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _isDownloading = false;
        
        if (objects) {
            [self addNextPosts:objects count:count];
        }
    }];
    
}

- (void)addNextPosts:(NSArray *)nextPosts count:(NSInteger)count {
    _postCount = count;
    [_posts addObjectsFromArray:nextPosts];
    [self.tableView reloadData];
}


// MARK:- UITableViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [self refreshPosts];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && _posts.count != _postCount && _isDownloading == false) {
        [self getNextPage];
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
        cell.indicatorIsHidden = _posts.count == _postCount;
        return cell;
    }
    EGFPost * post = _posts[indexPath.row];
    FeedPostCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    cell.creatorNameLabel.text = [post.creatorObject.name fullName];
    cell.descriptionLabel.text = post.desc;
    cell.postImage = nil;
    cell.post = post;
    
    if (post.imageObject) {
        [SimpleFileManager imageWithFile:post.imageObject completion:^(UIImage *image, BOOL fromCache) {
            // We must be ensure we show appropriate image for cell
            if (post != cell.post) {
                return;
            }
            if (image) {
                cell.postImage = image;
                
                if (!fromCache) {
                    [tableView beginUpdates];
                    [tableView endUpdates];
                }
            }
        }];
    }
    return cell;
}
@end
