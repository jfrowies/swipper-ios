//
//  LBCategory.h
//  swipper
//
//  Created by fernando rowies on 9/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <LoopBack/LoopBack.h>
#import "SWPCategory.h"

@interface LBCategory : LBModel <SWPCategory>

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *name;

@end
