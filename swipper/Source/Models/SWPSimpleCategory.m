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

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.name forKey:@"categoryName"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.name = [decoder decodeObjectForKey:@"categoryName"];
    }
    return self;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[SWPSimpleCategory class]]) {
        return NO;
    }
    
    return [self isEqualToPlace:(SWPSimpleCategory *)object];
}

- (NSUInteger)hash {
    return [self.name hash];
}

- (BOOL)isEqualToPlace:(SWPSimpleCategory *)place {
    if(!place) return false;
    return [self.name isEqualToString:place.name];
}

@end
