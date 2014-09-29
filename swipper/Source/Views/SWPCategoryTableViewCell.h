//
//  SWPCategoryTableViewCell.h
//  swipper
//
//  Created by fernando rowies on 9/18/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *categoryName;
@property (weak, nonatomic) IBOutlet UISwitch *categorySwitch;
@property (weak, nonatomic) IBOutlet UIView *categoryColorView;

@end
