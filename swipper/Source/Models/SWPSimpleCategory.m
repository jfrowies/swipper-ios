//
//  SWPCategorySimpleImplementation.m
//  swipper
//
//  Created by Fer Rowies on 10/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPSimpleCategory.h"

@implementation SWPSimpleCategory

+ (SWPSimpleCategory *)categoryWithName:(NSString *)categoryName
{
    SWPSimpleCategory *category= [[SWPSimpleCategory alloc] init];
    category.name = categoryName;
    return category;
}

- (NSString *)categoryName
{
    return self.name;
}


@end
