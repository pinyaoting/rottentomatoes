//
//  MovieViewController.m
//  Rotten Tomatoes
//
//  Created by Pythis Ting on 1/20/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "MovieViewController.h"
#import "MovieCell.h"
#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "Constants.h"

@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (weak, nonatomic) IBOutlet UILabel *errorMsg;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) NSString *apiEndpoint;

@end

@implementation MovieViewController

typedef enum {
    ROTTEN_TOMATOES_TAB_ENUM_MOVIE,
    ROTTEN_TOMATOES_TAB_ENUM_DVD
} ROTTEN_TOMATOES_TAB_ENUM;

- (void)viewDidLoad {
    [super viewDidLoad];

    [SVProgressHUD showWithStatus:LOADING];
    
    self.title = TITLE_MOVIE;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 128;
    [self.tableView registerNib:[UINib nibWithNibName:STREAM_CELL_NAME bundle:nil]forCellReuseIdentifier:STREAM_CELL_NAME];
    
    self.searchBar.delegate = self;
    
    self.tabBar.delegate = self;
    self.apiEndpoint = ROTTEN_TOMATOES_URL_MOVIE;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self onRefresh];
}

- (void)onRefresh {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.apiEndpoint]];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self.refreshControl endRefreshing];
        [SVProgressHUD dismiss];
        if (connectionError) {
            self.errorMsg.text = NETWORK_ERROR_MSG;
            self.errorMsg.hidden = NO;
            return;
        }
        //callback here
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        self.movies = responseDictionary[ROTTEN_TOMATOES_DATA_PATH];
        self.filteredMovies = [NSMutableArray arrayWithArray:self.movies];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailViewController *vc = [[MovieDetailViewController alloc] init];
    
    vc.movie = self.filteredMovies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell* cell = [tableView dequeueReusableCellWithIdentifier:STREAM_CELL_NAME];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    cell.titleLabel.text = movie[ROTTEN_TOMATOES_TITLE_PATH];
    cell.synopsisLabel.text = movie[ROTTEN_TOMATOES_SYNOPSIS_PATH];
    
    NSURL *imageUrl = [NSURL URLWithString:[movie valueForKeyPath:ROTTEN_TOMATOES_THUMBNAIL_PATH]];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0f];
    
    [cell.posterView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:cell.posterView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ cell.posterView.image = image;
        } completion:nil];
    } failure:nil];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    [self.filteredMovies removeAllObjects];
    
    // edge case handling
    if ([searchText isEqualToString:@""]) {
        self.filteredMovies = [NSMutableArray arrayWithArray:self.movies];
        [self.tableView reloadData];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    self.filteredMovies = [NSMutableArray arrayWithArray:[self.movies filteredArrayUsingPredicate:predicate]];
    
    [self.tableView reloadData];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    switch (item.tag) {
        case ROTTEN_TOMATOES_TAB_ENUM_DVD:
            self.apiEndpoint = ROTTEN_TOMATOES_URL_DVD;
            self.title = TITLE_DVD;
            break;
        case ROTTEN_TOMATOES_TAB_ENUM_MOVIE:
        default:
            self.apiEndpoint = ROTTEN_TOMATOES_URL_MOVIE;
            self.title = TITLE_MOVIE;
            break;
    }
        
    [self onRefresh];
}

@end
