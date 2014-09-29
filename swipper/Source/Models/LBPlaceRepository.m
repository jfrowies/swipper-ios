//
//  LBPlaceRepository.m
//  swipper
//
//  Created by fernando rowies on 9/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "LBPlaceRepository.h"
#import "LBPlace.h"

@implementation LBPlaceRepository
+ (instancetype)repository {
    LBPlaceRepository *repository = [self repositoryWithClassName:@"places"];
    repository.modelClass = [LBPlace class];
    return repository;
}
@end
