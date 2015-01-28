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
#import "SettingsViewController.h"

@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;
@property (strong, nonatomic) NSArray *movies;
@property (weak, nonatomic) IBOutlet UILabel *errorMsg;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) NSString *apiEndpoint;
@property (assign, nonatomic) NSInteger displayMode;

@end

@implementation MovieViewController

typedef enum {
    ROTTEN_TOMATOES_TAB_ENUM_MOVIE,
    ROTTEN_TOMATOES_TAB_ENUM_DVD
} ROTTEN_TOMATOES_TAB_ENUM;

typedef enum {
    ROTTEN_TOMATOES_DISPLAY_LIST,
    ROTTEN_TOMATOES_DISPLAY_GRID
} ROTTEN_TOMATOES_DISPLAY_ENUM;

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    long displayMode = [defaults integerForKey:@"displayMode"];
    switch (displayMode) {
        case ROTTEN_TOMATOES_DISPLAY_GRID:
            self.displayMode = ROTTEN_TOMATOES_DISPLAY_GRID;
            break;
        default:
            self.displayMode = ROTTEN_TOMATOES_DISPLAY_LIST;
            break;
    }
    [self onRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [SVProgressHUD showWithStatus:LOADING];
    
    // setup navigation bar
    self.title = TITLE_MOVIE;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"⚙" style:UIBarButtonItemStylePlain target:self action:@selector(onSettingsButton)];
    
    // setup table view
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 128;
    [self.tableView registerNib:[UINib nibWithNibName:STREAM_CELL_NAME bundle:nil]forCellReuseIdentifier:STREAM_CELL_NAME];
    
    // setup grid view
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    UINib *cellNib = [UINib nibWithNibName:@"GridCell" bundle:nil];
    [self.gridView registerNib:cellNib forCellWithReuseIdentifier:@"GridCell"];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 130)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.gridView setCollectionViewLayout:flowLayout];
    
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
        
        [self reloadData];
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    MovieDetailViewController *vc = [[MovieDetailViewController alloc] init];
    
    vc.movie = self.filteredMovies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    NSURL *imageUrl = [NSURL URLWithString:[movie valueForKeyPath:ROTTEN_TOMATOES_THUMBNAIL_PATH]];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0f];
    
    __weak UIImageView *gridPosterView = (UIImageView*)[cell viewWithTag:10];

    [gridPosterView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        UIImageView *strongRetainedPosterView = gridPosterView;
        
        [UIView transitionWithView:strongRetainedPosterView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ gridPosterView.image = image;
        } completion:nil];
    } failure:nil];
    
    return cell;
}

-(void)reloadData {
    switch (self.displayMode) {
        case ROTTEN_TOMATOES_DISPLAY_GRID:
            [self.gridView reloadData];
            self.gridView.hidden = NO;
            self.tableView.hidden = YES;
            break;
        default:
            [self.tableView reloadData];
            self.gridView.hidden = YES;
            self.tableView.hidden = NO;
            break;
    }
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
    
    [self reloadData];
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

- (void)onSettingsButton {
    SettingsViewController* svc = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

@end
