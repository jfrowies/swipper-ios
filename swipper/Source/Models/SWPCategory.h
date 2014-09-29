//
//  SWPCategory.h
//  swipper
//
//  Created by fernando rowies on 9/18/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SWPCategory <NSObject>
@property (nonatomic, copy, readonly) NSString *categoryName;
@property (nonatomic, copy, readonly) NSString *categoryId;
@end
