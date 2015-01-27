//
//  MovieDetailViewController.m
//  Rotten Tomatoes
//
//  Created by Pythis Ting on 1/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@interface MovieDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initScrollView];
    
    NSString *thumbnailUrl = [self.movie valueForKeyPath:ROTTEN_TOMATOES_THUMBNAIL_PATH];
    NSString *imageUrl = [[self.movie valueForKeyPath:ROTTEN_TOMATOES_ORIGINAL_PATH] stringByReplacingOccurrencesOfString:ROTTEN_TOMATOES_SUFFIX_TMB withString:ROTTEN_TOMATOES_SUFFIX_ORI];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0f];
    
    [self.posterView setImageWithURLRequest:request placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:self.posterView duration:2.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ self.posterView.image = image;
        } completion:nil];
    } failure:nil];
}

- (void) initScrollView {
    [self.scrollView addSubview:self.titleLabel];
    [self.scrollView addSubview:self.synopsisLabel];
    
    self.titleLabel.text = self.movie[ROTTEN_TOMATOES_TITLE_PATH];
    self.synopsisLabel.text = self.movie[ROTTEN_TOMATOES_SYNOPSIS_PATH];
    [self.synopsisLabel sizeToFit];
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews)
        contentRect = CGRectUnion(contentRect, view.frame);
    self.scrollView.contentSize = contentRect.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
