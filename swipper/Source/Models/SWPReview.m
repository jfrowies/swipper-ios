//
//  SWPSimpleReview.m
//  swipper
//
//  Created by Fer Rowies on 12/22/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPReview.h"

@implementation SWPReview

+ (SWPReview *)reviewWithText:(NSString *)reviewText andStars:(int)reviewStars{
    SWPReview *review = [[SWPReview alloc] init];
    review.placeReview = [NSString stringWithFormat:@"\"%@\"", reviewText];;
    review.placeStars = reviewStars;
    return review;
}

@end
