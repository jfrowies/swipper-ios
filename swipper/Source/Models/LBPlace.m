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

- (NSString *)placeName
{
    return self.name;
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

@end



