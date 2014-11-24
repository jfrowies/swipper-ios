//
//  LBPlace.m
//  swipper
//
//  Created by fernando rowies on 9/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "LBPlace.h"
#import <MapKit/MKMapView.h>

@implementation LBPlace

- (NSString *)placeId
{
    return self.Id;
}

- (NSString *)placeName
{
    return self.name;
}

- (NSString *)placeAddress
{
    return self.address;
}

- (NSString *)placePhone
{
    return self.phone;
}

- (CLLocationCoordinate2D)placeCoordinate
{
    NSString *latitude = (NSString *)[self.location valueForKey:@"lat"];
    NSString *longitude = (NSString *)[self.location valueForKey:@"lng"];
    
    return CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
}

- (NSString *)placeCategory
{
    return self.category;
}

- (NSString *)placeCity
{
    return self.city;
}

- (NSString *)placeState
{
    return self.state;
}
- (NSString *)placeCountry
{
    return self.country;
}

@end



