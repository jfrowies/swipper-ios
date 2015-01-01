//
//  SWPPlaceDetail.m
//  swipper
//
//  Created by Fer Rowies on 1/1/15.
//  Copyright (c) 2015 Globant Labs. All rights reserved.
//

#import "SWPPlaceDetail.h"

@implementation SWPPlaceDetail

+ (SWPPlaceDetail *)placeDetailForPlace:(NSString *)placeId withReviews:(NSArray *)reviews andPhotos:(NSArray *)photosRerquestsURLs {
    SWPPlaceDetail *placeDetail = [[SWPPlaceDetail alloc] init];
    placeDetail.placeId = placeId;
    placeDetail.reviews = reviews;
    placeDetail.photosRequestsURLs = photosRerquestsURLs;
    return placeDetail;
}

@end
