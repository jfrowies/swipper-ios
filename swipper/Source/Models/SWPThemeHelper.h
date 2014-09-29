//
//  SWPThemeHelper.h
//  swipper
//
//  Created by Fer Rowies on 9/28/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWPCategory.h"

@interface SWPThemeHelper : NSObject

+ (UIColor *)colorForNavigationBar;
+ (UIColor *)colorForMenuBackground;
+ (UIColor *)colorForCategory:(id<SWPCategory>)category;

@end
