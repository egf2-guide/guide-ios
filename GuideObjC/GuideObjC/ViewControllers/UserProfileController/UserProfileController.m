//
//  UserProfileController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 27.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UserProfileController.h"
#import "UIViewController+Additions.h"
#import "EGFHumanName+Additions.h"
#import "ProgressController.h"
#import "UIColor+Additions.h"
#import "EdgeDownloader.h"
#import "PostController.h"
#import "FollowButton.h"
#import "ProgressCell.h"
#import "Follows.h"

@interface UserProfileController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet FollowButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (retain, nonatomic) EdgeDownloader *feed;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@property (retain, nonatomic) UIRefreshControl *refreshControl;
@property (retain, nonatomic) NSString *currentUserId;
@end

@implementation UserProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cellHeights = [NSMutableDictionary dictionary];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor whiteColor];
    _refreshControl.tintColor = [UIColor hexColor:0x5E66B1];
    _tableView.refreshControl = _refreshControl;
    
    [_tableView registerNib:[UINib nibWithNibName:@"ProgressCell" bundle:nil] forCellReuseIdentifier:@"ProgressCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellReuseIdentifier:@"PostCell"];

    if (_profileUser) {
        _userNameLabel.text = [_profileUser.name fullName];
        _followButton.user = _profileUser;

        [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
            if ([object isKindOfClass:[EGFUser class]]) {
                _currentUserId = ((EGFUser *)object).id;
            }
            _feed = [[EdgeDownloader alloc] initWithSource:_profileUser.id edge:@"posts" expand:@[@"creator",@"image"]];
            _feed.tableView = _tableView;
            [_feed getNextPage];
        }];
    }
}

- (IBAction)followUser:(id)sender {
    if (_profileUser) {
        if ([[Follows shared] followStateForUser:_profileUser] == isFollow) {
            [[Follows shared] unfollowUser:_profileUser completion:^{
                [_followButton checkFollowState];
            }];
        }
        else {
            [[Follows shared] followUser:_profileUser completion:^{
                [_followButton checkFollowState];
            }];
        }
        [_followButton checkFollowState];
    }
}

// MARK:- PostCellDelegate
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
        [_feed refreshList];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EGFPost * post = (EGFPost *)[_feed objectAtIndex:indexPath.row];
        // Check if we already have the value
        NSNumber * height = _cellHeights[post.id];
        
        if (height) {
            return [height floatValue];
        }
        CGFloat newHeight = [PostCell heightForPost:post];
        _cellHeights[post.id] = [NSNumber numberWithFloat:newHeight];
        return newHeight;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PostController * controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PostController"];
        controller.post = (EGFPost *)[_feed objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:controller animated:true];
    }
}

// MARK:- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? _feed.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        ProgressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
        cell.indicatorIsHidden = tableView.refreshControl.isRefreshing || [_feed isDownloaded];
        return cell;
    }
    PostCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    cell.delegate = self;
    cell.post = (EGFPost *)[_feed objectAtIndex:indexPath.row];
    return cell;
}
@end
