//
//  OffensivePostsController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

#import "OffensivePostsController.h"
#import "OffendedUsersController.h"
#import "ProgressController.h"
#import "EdgeDownloader.h"
#import "ProgressCell.h"

@interface OffensivePostsController ()
@property (retain, nonatomic) EdgeDownloader *offensivePosts;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@property (retain, nonatomic) NSString *currentUserId;
@property (retain, nonatomic) NSString *currentRoleId;
@property (retain, nonatomic) NSArray *expand;
@property (retain, nonatomic) NSString *edge;
@end

@implementation OffensivePostsController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cellHeights = [NSMutableDictionary dictionary];
    _expand = @[@"creator",@"image"];
    _edge = @"offending_posts";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProgressCell" bundle:nil] forCellReuseIdentifier:@"ProgressCell"];
    
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        
        if ([object isKindOfClass:[EGFUser class]]) {
            _currentUserId = [object valueForKey:@"id"];
            
            [[Graph shared] objectsForSource:_currentUserId edge:@"roles" completion:^(NSArray * objects, NSInteger count, NSError * error) {
                if (objects) {
                    for (NSObject * object in objects) {
                        if ([object isMemberOfClass:[EGFAdminRole class]]) {
                            _currentRoleId = [object valueForKey:@"id"];
                            _offensivePosts = [[EdgeDownloader alloc] initWithSource:_currentRoleId edge:_edge expand:_expand];
                            _offensivePosts.tableView = self.tableView;
                            [_offensivePosts getNextPage];
                            break;
                        }
                    }
                }
            }];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isMemberOfClass:[OffendedUsersController class]] && [sender isKindOfClass:[OffensivePostCell class]]) {
        OffendedUsersController * controller = segue.destinationViewController;
        OffensivePostCell * cell = (OffensivePostCell *)sender;
        controller.offensivePost = cell.post;
    }
}

// MARK:- OffensivePostCellDelegate
- (void)deletePost:(EGFPost *)post {
    if (_currentRoleId && post.id) {
        [ProgressController show];
        [self.graph deleteObjectWithId:post.id forSource:_currentRoleId fromEdge:_edge completion:^(id object, NSError * error) {
            [ProgressController hide];
        }];
    }
}

- (void)confirmAsOffensive:(EGFPost *)post {
    if (post.id && post.creator) {
        [ProgressController show];
        [self.graph deleteObjectWithId:post.id forSource:post.creator fromEdge:@"posts" completion:^(id object, NSError * error) {
            [ProgressController hide];
            
            if (!error) {
                [self deletePost:post];
            }
        }];
    }
}

// MARK:- UITableViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshControl.isRefreshing) {
        [_offensivePosts refreshList];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EGFPost * post = (EGFPost *)[_offensivePosts objectAtIndex:indexPath.row];
        // Check if we already have the value
        NSNumber * height = _cellHeights[post.id];
        
        if (height) {
            return [height floatValue];
        }
        CGFloat newHeight = [OffensivePostCell heightForPost:post];
        _cellHeights[post.id] = [NSNumber numberWithFloat:newHeight];
        return newHeight;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && ![_offensivePosts isDownloaded]) {
        [_offensivePosts getNextPage];
    }
}

// MARK:- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? _offensivePosts.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        ProgressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
        cell.indicatorIsHidden = tableView.refreshControl.isRefreshing || [_offensivePosts isDownloaded];
        return cell;
    }
    OffensivePostCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OffensivePostCell"];
    cell.delegate = self;
    cell.post = (EGFPost *)[_offensivePosts objectAtIndex:indexPath.row];
    return cell;
}
@end
