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

@end
