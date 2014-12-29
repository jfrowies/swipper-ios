//
//  SWPMessageBarViewController.h
//  swipper
//
//  Created by Fer Rowies on 12/9/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MessageBarType){
    MessageBarInfo,
    MessageBarWarning,
    MessageBarError,
    MessageBarNoInternet,
    MessageBarInternetRestored
};

@interface SWPMessageBarViewController : UIViewController

@property (nonatomic) MessageBarType messageBarType;
@property (copy, nonatomic) NSString *message;
@property (nonatomic) BOOL isShowingMessage;

- (void)showMessage:(NSString *)message withBarType:(MessageBarType)barType animated:(BOOL)animated;
- (void)hideMessageAnimated:(BOOL)animated;
- (void)hideMessageAfterDelay:(NSTimeInterval)delay Animated:(BOOL)animated;

@end
