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
#import "TableViewHandler.h"
#import "FeedPostCell.h"
#import "EGF2.h"

@interface FeedController ()
@property (retain, nonatomic) TableViewHandler *posts;
@property (retain, nonatomic) NSString *currentUserId;
@property (assign, nonatomic) BOOL isDownloading;
@property (retain, nonatomic) NSArray * expand;
@property (retain, nonatomic) NSString * edge;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@end

@implementation FeedController

- (void)viewDidLoad {
    [super viewDidLoad];
    _posts = [[TableViewHandler alloc] initWithTableView:self.tableView];
    _cellHeights = [NSMutableDictionary dictionary];
    _expand = @[@"creator",@"image"];
    _edge = @"posts";
    
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            _currentUserId = ((EGFUser *)object).id;
            [self addObservers];
            [self getNextPage];
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObservers {
    if (_currentUserId) {
        NSObject * object = [self.graph notificationObjectForSource:_currentUserId andEdge:_edge];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(edgeDidCreate:) name:EGF2NotificationEdgeCreated object:object];
    }
}

- (void)edgeDidCreate:(NSNotification *)notification {
    NSString * postId = notification.userInfo[EGF2EdgeObjectIdInfoKey];
    
    if (postId) {
        // It's better to refresh object because 'post.imageObject.dimensions' can be nil right after creation of image
        [self.graph refreshObjectWithId:postId expand:_expand completion:^(NSObject * object, NSError * error) {
            [_posts insertObject:object atIndex:0];
        }];
    }
}

- (void)refreshPosts {
    if (!_currentUserId || _isDownloading) {
        return;
    }
    _isDownloading = true;
    [self.graph refreshObjectsForSource:_currentUserId edge:_edge after:nil expand:_expand completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _isDownloading = false;
        
        [_posts setObjects:objects totalCount:count];
        [self.refreshControl endRefreshing];
    }];
    
}

- (void)getNextPage {
    if (!_currentUserId || _isDownloading) {
        return;
    }
    _isDownloading = true;
    [self.graph objectsForSource:_currentUserId edge:_edge after:[_posts.last valueForKey:@"id"] expand:_expand completion:^(NSArray * objects, NSInteger count, NSError * error) {
        _isDownloading = false;
        
        [_posts addObjects:objects totalCount:count];
    }];
    
}

// MARK:- UITableViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [self refreshPosts];
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
    if (indexPath.section == 1 && ![_posts isDownloaded] && _isDownloading == false) {
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
