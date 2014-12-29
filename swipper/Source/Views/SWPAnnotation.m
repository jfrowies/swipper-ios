//
//  SWPAnnotation.m
//  swipper
//
//  Created by fernando rowies on 8/28/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPAnnotation.h"

@implementation SWPAnnotation

- (id)initWithPlace:(id<SWPPlace>)place
{
    self = [super init];
    if (self) {
        self.place = place;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.place.placeCoordinate;
}

- (NSString *)title
{
    return self.place.placeName;
}

- (NSString *)subtitle {
    
    CLLocation *startLocation = self.userLocation.location;
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[self.place placeCoordinate].latitude longitude:[self.place placeCoordinate].longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    
    return [NSString stringWithFormat:@"%.1f km",distance / 1000];
}

@end
