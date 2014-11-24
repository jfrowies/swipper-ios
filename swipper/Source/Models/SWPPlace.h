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
@property (nonatomic, readonly, copy) NSString *placeId;
@property (nonatomic, readonly, copy) NSString *placeName;
@property (nonatomic, readonly, copy) NSString *placeAddress;
@property (nonatomic, readonly, copy) NSString *placePhone;
@property (nonatomic, readonly) CLLocationCoordinate2D placeCoordinate;
@property (nonatomic, readonly, copy) NSString *placeCategory;
@property (nonatomic, readonly, copy) NSString *placeCity;
@property (nonatomic, readonly, copy) NSString *placeState;
@property (nonatomic, readonly, copy) NSString *placeCountry;
@end
