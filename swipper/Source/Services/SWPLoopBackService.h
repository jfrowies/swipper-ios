//
//  SWPLoopBackService.h
//  swipper
//
//  Created by fernando rowies on 9/1/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"
#import "SWPPlaceDetail.h"

@interface SWPLoopBackService : NSObject

@property (nonatomic, strong, readonly) NSURL *serviceURL;

+ (id)sharedInstance;

- (void)fetchPlacesBetweenNorthWest:(CLLocationCoordinate2D)northWestCoordinate
                          southEast:(CLLocationCoordinate2D)southEastCoordinate
                            success:(void (^) (NSArray *places))successBlock
                            failure:(void (^) (NSError *error))failureBlock;

- (void)fetchPlaceDetailWithPlaceId:(NSString *)placeId
                        success:(void (^) (SWPPlaceDetail *placeDetail))successBlock
                        failure:(void (^) (NSError *error))failureBlock;

@end
