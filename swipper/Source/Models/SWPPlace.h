//
//  SWPPlace.h
//  swipper
//
//  Created by fernando rowies on 9/11/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>

@protocol SWPPlace <NSObject>
@property (nonatomic, copy, readonly) NSString *placeName;
@property (nonatomic, copy, readonly) NSString *placeCategoryId;
@property (nonatomic, readonly) CLLocationCoordinate2D placeCoordinate;
@end
