//
//  SWPGalleryViewController.h
//  swipper
//
//  Created by Fer Rowies on 12/21/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface SWPGalleryViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, MWPhotoBrowserDelegate>
@property (strong, nonatomic) NSArray *photosReferences;
@end
