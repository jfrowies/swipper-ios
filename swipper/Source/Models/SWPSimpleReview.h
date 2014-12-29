//
//  SWPSimpleReview.h
//  swipper
//
//  Created by Fer Rowies on 12/22/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWPReview.h"

@interface SWPSimpleReview : NSObject <SWPReview>
@property (copy, nonatomic) NSString *reviewText;
@property (nonatomic) int reviewStars;
+ (SWPSimpleReview *)reviewWithText:(NSString *)reviewText andStars:(int)reviewStars;
@end
