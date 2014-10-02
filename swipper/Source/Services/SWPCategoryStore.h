//
//  SWPCategoryStore.h
//  swipper
//
//  Created by fernando rowies on 9/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWPCategoryStore : NSObject

@property (nonatomic, strong) NSArray *placesCategories;
@property (nonatomic, strong) NSArray *selectedCategories;

- (NSString *)categoryNameForId:(NSString *)categoryId;

+ (id)sharedInstance;

@end
