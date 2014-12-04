//
//  SWPCategoryTableViewCell.h
//  swipper
//
//  Created by fernando rowies on 9/18/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13Checkbox.h"
#import "SWPCategory.h"

@interface SWPCategoryTableViewCell : UITableViewCell

@property (strong, nonatomic) id<SWPCategory> category;
@property (weak, nonatomic) M13Checkbox *checkBox;
@end
