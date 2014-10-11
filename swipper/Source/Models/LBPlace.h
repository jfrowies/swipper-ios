//
//  LBPlace.h
//  swipper
//
//  Created by fernando rowies on 9/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <LoopBack/LoopBack.h>
#import "SWPPlace.h"

//Define a Local Objective C representation of the our LoopBack mobile model type
@interface LBPlace : LBModel <SWPPlace>

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *category;

@end
