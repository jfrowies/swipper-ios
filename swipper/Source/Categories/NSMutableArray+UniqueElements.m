//
//  NSArray+UniqueElements.m
//  swipper
//
//  Created by Fer Rowies on 12/4/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "NSMutableArray+UniqueElements.h"

@implementation NSMutableArray (UniqueElements)

- (void)addObjectIfNoExist:(id)object {
    BOOL objectAlreadyExist = NO;
    for (id obj in self) {
        if([obj isEqual:object]) objectAlreadyExist = YES;
    }
    if(!objectAlreadyExist) [self addObject:object];
}

@end
