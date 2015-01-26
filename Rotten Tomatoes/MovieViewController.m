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

@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (weak, nonatomic) IBOutlet UILabel *errorMsg;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SVProgressHUD showWithStatus:LOADING];
    self.title = STREAM_TITLE;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 128;
    [self.tableView registerNib:[UINib nibWithNibName:STREAM_CELL_NAME bundle:nil]forCellReuseIdentifier:STREAM_CELL_NAME];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self onRefresh];
}

- (void)onRefresh {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:ROTTEN_TOMATOES_URL_STRING]];

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
    
    vc.movie = self.movies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell* cell = [tableView dequeueReusableCellWithIdentifier:STREAM_CELL_NAME];
    
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[ROTTEN_TOMATOES_TITLE_PATH];
    cell.synopsisLabel.text = movie[ROTTEN_TOMATOES_SYNOPSIS_PATH];
    
    NSURL *imageUrl = [NSURL URLWithString:[movie valueForKeyPath:ROTTEN_TOMATOES_THUMBNAIL_PATH]];
    [cell.posterView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:imageUrl] placeholderImage:[UIImage imageNamed:MOVIE_POSTER_PLACEHOLDER_PATH] success:nil failure:nil];
    [cell.posterView setImageWithURL:[NSURL URLWithString:[movie valueForKeyPath:ROTTEN_TOMATOES_THUMBNAIL_PATH]]];
    return cell;
}

@end
