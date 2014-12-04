//
//  NSArray+UniqueElements.h
//  swipper
//
//  Created by Fer Rowies on 12/4/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (UniqueElements)
- (void)addObjectIfNoExist:(id)object;
@end
