//
//  SWPSimpleReview.m
//  swipper
//
//  Created by Fer Rowies on 12/22/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPSimpleReview.h"

@implementation SWPSimpleReview

+ (SWPSimpleReview *)reviewWithText:(NSString *)reviewText andStars:(int)reviewStars{
    SWPSimpleReview *review = [[SWPSimpleReview alloc] init];
    review.reviewText = reviewText;
     review.reviewStars = reviewStars;
    return review;
}

- (NSString *)placeReview{
    return self.reviewText;
}

- (int)placeStars {
    return self.reviewStars;
}


@end
