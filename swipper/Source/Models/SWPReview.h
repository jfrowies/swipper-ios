//
//  SWPSimpleReview.h
//  swipper
//
//  Created by Fer Rowies on 12/22/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWPReview : NSObject
@property (nonatomic, copy) NSString *placeReview;
@property (nonatomic) int placeStars;
+ (SWPReview *)reviewWithText:(NSString *)reviewText andStars:(int)reviewStars;
@end
