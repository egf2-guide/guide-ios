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
#import "UIColor+Additions.h"
#import "FeedProgressCell.h"
#import "SearchDownloader.h"
#import "EdgeDownloader.h"
#import "PostController.h"
#import "EGF2.h"

@interface FeedController ()
@property (retain, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *createPostButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *listSegment;
@property (retain, nonatomic) BaseDownloader *activeDownloader;
@property (retain, nonatomic) SearchDownloader *searching;
@property (retain, nonatomic) EdgeDownloader *timeline;
@property (retain, nonatomic) EdgeDownloader *feed;
@property (retain, nonatomic) NSMutableDictionary * cellHeights;
@property (retain, nonatomic) UISearchBar * searchBar;
@property (retain, nonatomic) NSString *currentUserId;
@property (retain, nonatomic) NSArray *expand;
@property (retain, nonatomic) NSString *edge;
@end

@implementation FeedController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cellHeights = [NSMutableDictionary dictionary];
    _expand = @[@"creator",@"image"];
    _edge = @"posts";
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = true;
    _searchBar.tintColor = [UIColor hexColor:0x5E66B1];
    
    EGF2SearchParameters * parameters = [EGF2SearchParameters parametersWithObject:@"post"];
    parameters.fields = @[@"desc"];
    parameters.expand = _expand;
    _searching = [[SearchDownloader alloc] initWithParameters:parameters];
    
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            _currentUserId = [object valueForKey:@"id"];
            _timeline = [[EdgeDownloader alloc] initWithSource:_currentUserId edge:@"timeline" expand:_expand];
            _feed = [[EdgeDownloader alloc] initWithSource:_currentUserId edge:_edge expand:_expand];
            _feed.tableView = self.tableView;
            [_feed getNextPage];
            _activeDownloader = _feed;
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_searchBar.text.length > 0) {
        [_searchBar becomeFirstResponder];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isMemberOfClass:[PostController class]] && [sender isKindOfClass:[UITableViewCell class]]) {
        PostController * postController = segue.destinationViewController;
        NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
        postController.post = (EGFPost *)[_activeDownloader objectAtIndex:indexPath.row];
        [_searchBar resignFirstResponder];
    }
}

- (void)setActiveDownloader:(EdgeDownloader *)activeDownloader {
    if (_activeDownloader) {
        _activeDownloader.tableView = nil;
    }
    _activeDownloader = activeDownloader;
    
    if (_activeDownloader) {
        _activeDownloader.tableView = self.tableView;
    }
}

- (IBAction)changeList:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.activeDownloader = _feed;
    }
    else if (sender.selectedSegmentIndex == 1) {
        self.activeDownloader = _timeline;
    }
}

// MARK:- Searching
- (IBAction)beginSearch:(UISegmentedControl *)sender {
    self.activeDownloader = _searching;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.titleView = _searchBar;
    [_searchBar becomeFirstResponder];
}

- (void)endSearch {
    [self changeList:_listSegment];
    _searchBar.text = nil;
    self.navigationItem.rightBarButtonItem = _createPostButton;
    self.navigationItem.leftBarButtonItem = _searchButton;
    self.navigationItem.titleView = _listSegment;
}

// MARK:- UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self endSearch];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        [self endSearch];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searching showObjectsWithQuery:searchText];
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
        [_activeDownloader refreshList];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EGFPost * post = (EGFPost *)[_activeDownloader objectAtIndex:indexPath.row];
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
    if (indexPath.section == 1 && ![_activeDownloader isDownloaded]) {
        [_activeDownloader getNextPage];
    }
}

// MARK:- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? _activeDownloader.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        FeedProgressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
        cell.indicatorIsHidden = tableView.refreshControl.isRefreshing || [_activeDownloader isDownloaded];
        return cell;
    }
    FeedPostCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    cell.delegate = self;
    cell.post = (EGFPost *)[_activeDownloader objectAtIndex:indexPath.row];
    return cell;
}
@end
