//
//  SWPLoopBackService.h
//  swipper
//
//  Created by fernando rowies on 9/1/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

@interface SWPLoopBackService : NSObject

@property (nonatomic, strong, readonly) NSURL *serviceURL;

+ (id)sharedInstance;

//- (void)fetchAllCategoriesSuccess:(void (^) (NSArray *categories))successBlock
//                           failure:(void (^) (NSError *error))failureBlock;

- (void)fetchPlacesBetweenNorthWest:(CLLocationCoordinate2D)northWestCoordinate
                          southEast:(CLLocationCoordinate2D)southEastCoordinate
                            success:(void (^) (NSArray *places))successBlock
                            failure:(void (^) (NSError *error))failureBlock;

- (void)fetchPlaceReviewsWithPlaceId:(NSString *)placeId
                        success:(void (^) (NSArray *reviews))successBlock
                        failure:(void (^) (NSError *error))failureBlock;

@end
