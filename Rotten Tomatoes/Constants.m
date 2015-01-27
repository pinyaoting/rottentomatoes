//
//  Constants.m
//  Rotten Tomatoes
//
//  Created by Pythis Ting on 1/25/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

NSString *const ROTTEN_TOMATOES_TITLE_PATH = @"title";
NSString *const ROTTEN_TOMATOES_SYNOPSIS_PATH = @"synopsis";
NSString *const ROTTEN_TOMATOES_URL_MOVIE = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5";
NSString *const ROTTEN_TOMATOES_URL_DVD = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals?apikey=dagqdghwaq3e3mxyrp7kmmj5";
NSString *const ROTTEN_TOMATOES_DATA_PATH = @"movies";
NSString *const ROTTEN_TOMATOES_THUMBNAIL_PATH = @"posters.thumbnail";
NSString *const ROTTEN_TOMATOES_ORIGINAL_PATH = @"posters.original";
NSString *const MOVIE_POSTER_PLACEHOLDER_PATH = @"cinema.png";
NSString *const STREAM_CELL_NAME = @"MovieCell";
NSString *const TITLE_MOVIE = @"Top Movies";
NSString *const TITLE_DVD = @"Top DVD Rentals";
NSString *const NETWORK_ERROR_MSG = @"Network Error";
NSString *const LOADING = @"Loading";

NSString *const ROTTEN_TOMATOES_SUFFIX_TMB = @"_tmb";
NSString *const ROTTEN_TOMATOES_SUFFIX_ORI = @"_ori";