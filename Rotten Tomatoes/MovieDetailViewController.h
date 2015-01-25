//
//  MovieDetailViewController.h
//  Rotten Tomatoes
//
//  Created by Pythis Ting on 1/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@property (nonatomic, strong) NSDictionary *movie;
@end
