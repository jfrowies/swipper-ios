//
//  SWPPlaceDetail.h
//  swipper
//
//  Created by Fer Rowies on 1/1/15.
//  Copyright (c) 2015 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWPPlaceDetail : NSObject

@property (copy, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSURL *placeURL;
@property (strong, nonatomic) NSArray *reviews;
@property (strong, nonatomic) NSArray *photosRequestsURLs;

+ (SWPPlaceDetail *)placeDetailForPlace:(NSString *)placeId url:(NSURL *)placeURL withReviews:(NSArray *)reviews andPhotos:(NSArray *)photosRerquestsURLs;

@end
