//
//  LBCategoryRepository.m
//  swipper
//
//  Created by fernando rowies on 9/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "LBCategoryRepository.h"
#import "LBCategory.h"

@implementation LBCategoryRepository
+ (instancetype)repository {
    LBCategoryRepository *repository = [self repositoryWithClassName:@"categories"];
    repository.modelClass = [LBCategory class];
    return repository;
}
@end
