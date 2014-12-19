//
//  SWPAnnotation.h
//  swipper
//
//  Created by fernando rowies on 8/28/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SWPPlace.h"

@interface SWPAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) id<SWPPlace> place;
@property (nonatomic, strong) MKUserLocation *userLocation;

- (id)initWithPlace:(id<SWPPlace>)place;

@end