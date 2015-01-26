//
//  MovieDetailViewController.m
//  Rotten Tomatoes
//
//  Created by Pythis Ting on 1/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    
    NSString* imageUrl = [[self.movie valueForKeyPath:@"posters.original"] stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    
    [self.posterView setImageWithURL:[NSURL URLWithString:imageUrl]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
