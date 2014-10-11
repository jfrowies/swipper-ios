//
//  SWPThemeHelper.m
//  swipper
//
//  Created by Fer Rowies on 9/28/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPThemeHelper.h"

@implementation SWPThemeHelper

+ (UIColor *)colorForNavigationBar
{
    return [UIColor colorWithRed:255/255.0f green:194/255.0f blue:0/255.0f alpha:1.0f];
}

+ (UIColor *)colorForMenuBackground
{
     return [UIColor colorWithRed:35/255.0f green:32/255.0f blue:32/255.0f alpha:1.0f];
}

+ (UIColor *)colorForCategory:(id<SWPCategory>)category
{
    if([category.categoryName isEqualToString:@"Lodging"])
        return [UIColor colorWithRed:0/255.0f green:75/255.0f blue:192/255.0f alpha:1.0f];
    
    if([category.categoryName isEqualToString:@"Car Rental"])
        return [UIColor colorWithRed:161/255.0f green:194/255.0f blue:11/255.0f alpha:1.0f];
    
    if([category.categoryName isEqualToString:@"Food"])
        return [UIColor colorWithRed:218/255.0f green:27/255.0f blue:92/255.0f alpha:1.0f];
    
    if([category.categoryName isEqualToString:@"Gas"])
        return [UIColor colorWithRed:0/255.0f green:204/255.0f blue:195/255.0f alpha:1.0f];
    
//    if([category.categoryName isEqualToString:@"Lodging Small"])
//        return [UIColor colorWithRed:0/255.0f green:75/255.0f blue:192/255.0f alpha:1.0f];
    
    if([category.categoryName isEqualToString:@"Taxi"])
        return [UIColor colorWithRed:137/255.0f green:85/255.0f blue:233/255.0f alpha:1.0f];
        
    return [self colorForNavigationBar];
}

@end
