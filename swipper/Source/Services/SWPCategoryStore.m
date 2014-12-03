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

#pragma mark - Setters/Getters

#define AppSelectedCategoriesKey @"appSelectedCategoriesKey"

- (void)setSelectedCategories:(NSArray *)selectedCategories {
    _selectedCategories = selectedCategories;
    
    //saving selected categories in NSUserDefaults
    NSMutableArray *encodedCategories = [NSMutableArray arrayWithCapacity:selectedCategories.count];
    
    for (SWPSimpleCategory *category in selectedCategories) {
        [encodedCategories addObject: [NSKeyedArchiver archivedDataWithRootObject:category]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:encodedCategories forKey:AppSelectedCategoriesKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
        
        NSArray *encodedCategories = [[NSUserDefaults standardUserDefaults] objectForKey:AppSelectedCategoriesKey];
        
        NSMutableArray *selectedCategories = [NSMutableArray array];
        
        if(encodedCategories) {
            for (NSData *encodedCategory in encodedCategories) {
                [selectedCategories addObject:[NSKeyedUnarchiver unarchiveObjectWithData:encodedCategory]];
            }
        }
        
        if(selectedCategories.count > 0) {
            _selectedCategories = selectedCategories;
        }else{
            _selectedCategories = [categoriesArray copy];
        }

    }
    return self;
}

@end
