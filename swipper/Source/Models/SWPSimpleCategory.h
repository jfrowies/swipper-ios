//
//  SWPCategorySimpleImplementation.h
//  swipper
//
//  Created by Fer Rowies on 10/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWPCategory.h"

@interface SWPSimpleCategory : NSObject <SWPCategory>

@property (nonatomic, copy) NSString *name;

+ (SWPSimpleCategory *)categoryWithName:(NSString *)categoryName;

@end
