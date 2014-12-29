//
//  SWPReview.h
//  swipper
//
//  Created by Fer Rowies on 12/22/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>

@protocol SWPReview <NSObject>
@property (nonatomic, readonly, copy) NSString *placeReview;
@property (nonatomic, readonly) int placeStars;
@end
