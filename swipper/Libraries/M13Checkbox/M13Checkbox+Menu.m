//
//  M13Checkbox+Menu.m
//  swipper
//
//  Created by Fer Rowies on 11/4/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "M13Checkbox+Menu.h"

@implementation M13Checkbox(Menu)

+ (M13Checkbox *)checkboxForMenu {
    M13Checkbox *check = [[M13Checkbox alloc] initWithFrame:CGRectMake(0, 0, 17.0f, 17.0f)];
    check.checkColor = [UIColor whiteColor];
    check.strokeColor = [UIColor whiteColor];
    check.tintColor = [UIColor clearColor];
    return check;
}

@end
