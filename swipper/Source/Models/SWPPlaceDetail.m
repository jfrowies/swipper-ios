//
//  SWPPlaceDetail.m
//  swipper
//
//  Created by Fer Rowies on 1/1/15.
//  Copyright (c) 2015 Globant Labs. All rights reserved.
//

#import "SWPPlaceDetail.h"

@implementation SWPPlaceDetail

+ (SWPPlaceDetail *)placeDetailForPlace:(NSString *)placeId url:(NSURL *)placeURL withReviews:(NSArray *)reviews andPhotos:(NSArray *)photosReferences {
    SWPPlaceDetail *placeDetail = [[SWPPlaceDetail alloc] init];
    placeDetail.placeId = placeId;
    placeDetail.placeURL = placeURL;
    placeDetail.reviews = reviews;
    placeDetail.photosReferences = photosReferences;
    return placeDetail;
}

@end
