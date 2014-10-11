//
//  SWPCategoryStore.m
//  swipper
//
//  Created by fernando rowies on 9/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPCategoryStore.h"
#import "SWPCategory.h"
#import "SWPSimpleCategory.h"

@implementation SWPCategoryStore

#pragma mark - 

//- (NSString *)categoryNameForId:(NSString *)categoryId
//{
//    for (id<SWPCategory> category in self.placesCategories) {
//        if([[category categoryId] isEqualToString:categoryId]) return [category categoryName];
//    }
//    
//    return @"defaultPin";
//}

#pragma mark - Singleton implementation

+ (id)sharedInstance {
    static SWPCategoryStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        //populate from settings or some type of cache
        
        NSArray *categoriesArray = [NSArray arrayWithObjects:
                                    [SWPSimpleCategory categoryWithName:@"Food"],
                                    [SWPSimpleCategory categoryWithName:@"Gas"],
                                    [SWPSimpleCategory categoryWithName:@"Lodging"],
                                    [SWPSimpleCategory categoryWithName:@"Taxi"],
                                    [SWPSimpleCategory categoryWithName:@"Car Rental"],nil];
        
        self.placesCategories = [categoriesArray copy];
        self.selectedCategories = [categoriesArray copy];
    }
    return self;
}

@end
